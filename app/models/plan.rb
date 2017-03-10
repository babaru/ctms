class Plan < ApplicationRecord
  has_many :plan_projects
  has_many :projects, through: :plan_projects
  has_many :executions

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  def title
    name
  end

  def finished?
    state == PlanState.enums.finished
  end

  def unfinished?
    !finished?
  end

  class << self

  def states
    PlanState.enums.map{ |k,v| [I18n.t("plan_states.#{k}"),v] }
  end

  def state_names
    PlanState.enums.map{ |k,v| [v, I18n.t("plan_states.#{k}")] }.to_h
  end

  end
end
