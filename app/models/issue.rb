class Issue < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :milestone, optional: true
  belongs_to :user, optional: true
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id, optional: true
  has_many :scenarios
  has_many :issue_labels
  has_many :labels, through: :issue_labels
  has_many :time_sheets

  # scope :labels, -> { |labels| where(label_ids.include?}

  def nav_title
    scenarios_count = scenarios.count > 0 ? " [#{scenarios.count}]" : ''
    "#{list_title}#{scenarios_count}"
  end

  def list_title
    "##{gitlab_id} - #{title}"
  end

  def opened?
    state == 'opened'
  end

  def self.sync_from_gitlab(project, api = nil)
    api ||= GitLabAPI.instance
    project.issues.update(is_existing_on_gitlab: false)
    collection_data = api.issues(project.gitlab_id)
    total_pages = api.total_pages(collection_data).to_i

    1.upto(total_pages) do |page|
      collection_data.each do |data|
        milestone = Milestone.from_gitlab_data(project, data["milestone"])
        labels = Label.from_gitlab_data(project, data["labels"])
        user = User.from_gitlab_data(data["author"])
        assignee = User.from_gitlab_data(data["assignee"])
        from_gitlab_data(project, milestone, labels, user, assignee, data)
      end
      collection_data = api.issues(project.gitlab_id, page + 1) if page < total_pages
    end
  end

  def self.from_gitlab_data(project, milestone, labels, user, assignee, data)
    return nil unless data
    issue = where(gitlab_id: data["id"]).first_or_create
    data_attrs = {}
    %w(title description state created_at updated_at).each do |str|
      data_attrs[str.to_sym] = data[str] if data[str]
    end
    data_attrs[:gitlab_iid] = data["iid"]
    data_attrs[:is_existing_on_gitlab] = true
    data_attrs[:project] = project
    data_attrs[:milestone] = milestone
    data_attrs[:labels] = labels
    data_attrs[:user] = user
    data_attrs[:assignee] = assignee
    issue.update(data_attrs)
    issue
  end
end
