class Defect < Issue
  belongs_to :corresponding_issue, class_name: 'Issue', optional: true

  scope :current_round, ->(round) { where(round_id: round) }
  scope :current_issue, ->(issue) { where(issue_id: issue) }
end
