class Project < ApplicationRecord
  include Watchable

  has_many :issues
  has_many :milestones
  has_many :scenarios
  has_many :plan_projects
  has_many :plans, through: :plan_projects
  has_many :labels
  has_many :user_watching_projects
  has_many :users, through: :user_watching_projects
  has_many :time_sheets

  validates :gitlab_id, presence: true, uniqueness: true

  scope :watched, ->(user) { joins(:users).where(users: { id: user }) }
  scope :time_tracking, -> { where(under_time_tracking: true) }

  def time_tracking?
    !!under_time_tracking
  end

  def requirements
    issues.joins(:labels).where(labels: { is_requirement: true })
  end

  def title
    "#{namespace} / #{name}"
  end

  class << self

  def sync_from_gitlab(api)
    api ||= GitLabAPI.instance

    Project.all.update(is_existing_on_gitlab: false)
    collection_data = api.projects
    total_pages = api.total_pages(collection_data).to_i

    1.upto(total_pages).each do |page|
      api.projects.each {|data| from_gitlab_data(data) }
      collection_data = api.projects(page + 1) if page < total_pages
    end
  end

  def from_gitlab_data(data)
    return nil unless data
    project = where(gitlab_id: data["id"]).first_or_create
    data_attrs = {}
    data_attrs[:name] = data["name"]
    %w(description path_with_namespace).each do |str|
      data_attrs[str.to_sym] = data[str] if data[str]
    end
    data_attrs[:namespace] = data["namespace"]["name"]
    data_attrs[:is_existing_on_gitlab] = true
    project.update(data_attrs)
    project
  end

  end
end
