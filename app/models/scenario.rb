class Scenario < ApplicationRecord
  belongs_to :project
  belongs_to :issue
  has_many :executions, dependent: :destroy
  has_many :scenario_labels, dependent: :destroy
  has_many :labels, through: :scenario_labels
  has_many :defects

  validates :title, presence: true

  attr_accessor :labels_text

  scope :no_label, -> { where.not(id: Scenario.has_label.select(:id).distinct) }
  scope :has_label, -> {
    joins(:labels).where({
      labels: {
          id: Label.select(:id)
        }
    }).distinct
  }
  scope :label, ->(label) { joins(:labels).where(labels: { id: label }).distinct }
  scope :execution_result, ->(plan, result) { joins(:executions).where(executions: { plan_id: plan, result: result }) }
  scope :unexecuted, ->(plan) { where.not(id: Scenario.execution_result(plan, [ExecutionResult.enums.passed, ExecutionResult.enums.failed, ExecutionResult.enums.na]).select(:id).distinct) }

  def html_body
    Kramdown::Document.new(body).to_html.html_safe
  end

  def execution(round)
    executions.where(round_id: round).first
  end

  def self.parse_labels(labels_text, project)
    return [] if labels_text.nil?
    labels_text.gsub('，', ',').split(',').inject([]) do |list, text|
      list << Label.where(name: text, project_id: project).first_or_create
    end
  end

end
