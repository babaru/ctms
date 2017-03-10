class Project < ApplicationRecord
  has_many :issues
  has_many :milestones
  has_many :scenarios
  has_many :plan_projects
  has_many :plans, through: :plan_projects
  has_many :labels

  validates :gitlab_id, presence: true, uniqueness: true

  scope :watched, ->{ where(is_watched: true) }

  def title
    "#{namespace} / #{name}"
  end

  def unwatched?
    !watched?
  end

  def watched?
    is_watched
  end

  class << self

  def sync_from_gitlab(api)
    api ||= GitLabAPI.instance

    Project.all.update(is_existing_on_gitlab: false)
    projects_data = api.projects
    total_pages = api.total_pages(projects_data).to_i

    1.upto(total_pages).each do |page|

      api.projects.each do |project_data|
        logger.debug project_data["path_with_namespace"]
        project = Project.find_by_gitlab_id(project_data["id"]) || Project.create(gitlab_id: project_data["id"])
        project.update(
          name: project_data["name"],
          namespace: project_data["namespace"]["name"],
          path: project_data["path_with_namespace"],
          gitlab_id: project_data["id"],
          is_existing_on_gitlab: true)
      end

      projects_data = api.projects(page + 1) if page < total_pages

    end
  end

  end
end
