class Scenario < ApplicationRecord
  belongs_to :project
  belongs_to :issue
  has_many :executions
  has_many :scenario_labels
  has_many :labels, through: :scenario_labels

  validates :name, presence: true

  attr_accessor :labels_text

  def title
    name
  end

  def execution(plan_id)
    executions.where(plan_id: plan_id).first
  end

  def self.parse_labels(labels_text, project)
    labels_text.gsub('，', ',').split(',').inject([]) do |list, text|
      list << Label.where(name: text, project_id: project).first_or_create
    end
  end

end
