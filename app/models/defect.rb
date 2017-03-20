class Defect << Issue
  belongs_to :corresponding_issue, class_name: 'Issue', optional: true
end
