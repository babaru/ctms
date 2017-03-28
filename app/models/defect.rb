class Defect < Issue
  scope :current_round, ->(round) { where(round_id: round) }
  scope :current_issue, ->(issue) { where(issue_id: issue) }
  scope :current_scenario, ->(scenario) { where(scenario_id: scenario) }

  belongs_to :scenario, optional: true

  attr_accessor :labels_text

  def post_defect_to_gitlab(access_token)
    data = GitLabAPI.instance.create_issue(
      project.gitlab_id,
      title,
      description,
      corresponding_issue.milestone ? corresponding_issue.milestone.gitlab_id : nil,
      labels_text,
      access_token
    )
    # Defect.from_gitlab_data(project, data)
    self.milestone = Milestone.from_gitlab_data(project, data["milestone"])
    self.labels = Label.from_gitlab_data(project, data["labels"])
    self.user = User.from_gitlab_data(data["author"])
    self.gitlab_id = data["id"]
    self.gitlab_iid = data["iid"]
    self.is_existing_on_gitlab = true
    self.state = data["state"]
    # assignee = User.from_gitlab_data(data["assignee"])
    self.save
  end
end
