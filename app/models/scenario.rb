class Scenario < ApplicationRecord
  belongs_to :project
  belongs_to :issue
  has_many :executions, dependent: :destroy
  has_many :scenario_labels, dependent: :destroy
  has_many :labels, through: :scenario_labels

  validates :name, presence: true

  attr_accessor :labels_text

  def title
    name
  end

  def html_body
    Kramdown::Document.new(body).to_html.html_safe
  end

  def execution(plan_id)
    executions.where(plan_id: plan_id).first
  end

  def self.parse_labels(labels_text, project)
    return [] if labels_text.nil?
    labels_text.gsub('，', ',').split(',').inject([]) do |list, text|
      list << Label.where(name: text, project_id: project).first_or_create
    end
  end

end
