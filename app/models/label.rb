class Label < ApplicationRecord
  belongs_to :project
  has_many :issue_labels
  has_many :issues, through: :issue_labels
  has_many :scenario_labels
  has_many :scenarios, through: :scenario_labels

  scope :requirements, -> { where(is_requirement: true) }
  scope :used_by_scenarios, ->(project) { joins(:scenarios).where(scenarios: { project_id: project }).distinct }

  def is_requirement?
    !!is_requirement
  end

  def self.from_gitlab_data(project, data)
    data.inject([]) do |list, label_name|
      list << where(project: project, name: label_name).first_or_create
    end
  end
end
