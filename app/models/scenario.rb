class Scenario < ApplicationRecord
  belongs_to :project
  belongs_to :issue
  has_many :executions

  def title
    name
  end

  def execution(plan_id)
    executions.where(plan_id: plan_id).first
  end
end
