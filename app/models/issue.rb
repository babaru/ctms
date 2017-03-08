class Issue < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :milestone, optional: true
  has_many :scenarios

  serialize :labels, Array

  def title
    "[#{gitlab_id.rjust(3, '0')}] - #{name}"
  end

  class << self

  def sync_from_gitlab(gitlab_project_id, api)
    api ||= GitLabAPI.instance
    issues_data = api.issues(gitlab_project_id)
    total_pages = api.total_pages(issues_data).to_i

    project = Project.find_by_gitlab_id(gitlab_project_id)

    1.upto(total_pages) do |page|
      issues_data.each do |issue_data|
        next if issue_data.nil?
        milestone = nil
        milestone_data = issue_data["milestone"]
        unless milestone_data.nil?
          milestone = Milestone.find_by_gitlab_id(milestone_data["id"]) || Milestone.create
          milestone.update(
            name: milestone_data["title"],
            # description: milestone_data["description"],
            gitlab_id: milestone_data["id"],
            gitlab_iid: milestone_data["iid"],
            project: project
          )
        end
        issue = Issue.find_by_gitlab_id(issue_data["id"]) || Issue.create
        issue.update(name: issue_data["title"],
          gitlab_id: issue_data["id"],
          gitlab_iid: issue_data["iid"],
          body: issue_data["description"],
          is_existing_on_gitlab: true,
          project: project,
          milestone: milestone)
      end
      issues_data = api.issues(gitlab_project_id, page + 1) if page < total_pages
    end
  end

  end
end
