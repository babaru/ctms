class Plan < ApplicationRecord
  has_many :plan_projects
  has_many :projects, through: :plan_projects
  has_many :executions

  def title
    name
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
