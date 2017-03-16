class Label < ApplicationRecord
  belongs_to :project
  has_many :issue_labels, dependent: :destroy
  has_many :issues, through: :issue_labels
  has_many :scenario_labels, dependent: :destroy
  has_many :scenarios, through: :scenario_labels

  scope :requirements, -> { where(is_requirement: true) }
  scope :used_by_scenarios, ->(project) { joins(:scenarios).where(scenarios: { project_id: project }).distinct }
  scope :used_by_issues, ->(project) { joins(:issues).where(issues: { project_id: project }).distinct }

  def is_requirement?
    !!is_requirement
  end

  def is_existing_on_gitlab?
    !!is_existing_on_gitlab
  end

  def self.from_gitlab_data(project, data)
    data.inject([]) do |list, label_name|
      label = where(project: project, name: label_name).first_or_create
      label.update(is_existing_on_gitlab: true)
      list << label
    end
  end
end
