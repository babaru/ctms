class Project < ApplicationRecord
  has_many :issues
  has_many :milestone
  has_many :scenarios

  validates :name, presence: true, uniqueness: true

  def title
    name
  end

  class << self

  def sync_from_gitlab(api)
    api ||= GitLabAPI.instance

    Project.all.update(is_existing_on_gitlab: false)
    projects_data = api.projects
    total_pages = api.total_pages(projects_data).to_i

    1.upto(total_pages).each do |page|

      api.projects.each do |project_data|
        project = Project.find_by_gitlab_id(project_data["id"]) || Project.create(name: project_data["name_with_namespace"], gitlab_id: project_data["id"])
        project.update(name: project_data["name_with_namespace"],
          gitlab_id: project_data["id"],
          is_existing_on_gitlab: true)
      end

      projects_data = api.projects(page + 1) if page < total_pages

    end
  end

  end
end
