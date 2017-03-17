class Plan < ApplicationRecord
  include Watchable

  has_many :plan_projects, dependent: :destroy
  has_many :projects, through: :plan_projects
  has_many :executions, dependent: :destroy

  has_many :user_watching_plans, dependent: :destroy
  has_many :users, through: :user_watching_plans

  validates :name, presence: true
  validates :started_at, presence: true
  validates :ended_at, presence: true

  scope :watched, ->(user) { joins(:users).where(users: { id: user }) }

  def title
    name
  end

  def finished?
    state == PlanState.enums.finished
  end

  def unfinished?
    !finished?
  end

  def total_scenarios_count
    projects.inject(0) {|sum, project| sum += project.scenarios.count }
  end

  def progress
    executions.count * 100 / total_scenarios_count
  end

  def finish
    state = self.state == PlanState.enums.finished ? PlanState.enums.unfinished : PlanState.enums.finished
    self.update(state: state)
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
