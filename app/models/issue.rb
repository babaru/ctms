class Issue < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :milestone, optional: true
  has_many :scenarios
  has_many :issue_labels
  has_many :labels, through: :issue_labels

  serialize :labels, Array

  # scope :labels, -> { |labels| where(label_ids.include?}

  def title
    # "[#{gitlab_id.rjust(3, '0')}] - #{name}"
    name
  end

  def nav_title
    scenarios_count = scenarios.count > 0 ? " [#{scenarios.count}]" : ''
    "#{name}#{scenarios_count}"
  end

  class << self

  def sync_from_gitlab(gitlab_project_id, api)
    api ||= GitLabAPI.instance

    project = Project.find_by_gitlab_id(gitlab_project_id)
    project.issues.update(is_existing_on_gitlab: false)
    project.milestones.update(is_existing_on_gitlab: false)

    issues_data = api.issues(gitlab_project_id)
    total_pages = api.total_pages(issues_data).to_i

    1.upto(total_pages) do |page|
      issues_data.each do |issue_data|
        next if issue_data.nil?

        milestone = nil
        milestone_data = issue_data["milestone"]
        unless milestone_data.nil?
          milestone = Milestone.find_by_gitlab_id(milestone_data["id"]) || Milestone.create
          milestone.update(
            name: milestone_data["title"],
            description: milestone_data["description"],
            gitlab_id: milestone_data["id"],
            gitlab_iid: milestone_data["iid"],
            project: project,
            is_existing_on_gitlab: true
          )
        end

        issue = Issue.find_by_gitlab_id(issue_data["id"]) || Issue.create
        label_ids = issue_data["labels"].inject([]) do |list, label_text|
          label = Label.find_by_project_id_and_name(project.id, label_text) || Label.create(project_id: project.id, name: label_text)
          list << label.id
        end

        issue.update(name: issue_data["title"],
          gitlab_id: issue_data["id"],
          gitlab_iid: issue_data["iid"],
          body: issue_data["description"],
          label_ids: label_ids,
          state: issue_data["state"],
          is_existing_on_gitlab: true,
          project: project,
          milestone: milestone)
      end
      issues_data = api.issues(gitlab_project_id, page + 1) if page < total_pages
    end
  end

  end
end
