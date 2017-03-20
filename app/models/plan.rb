class Plan < ApplicationRecord
  include Watchable

  has_many :plan_projects, dependent: :destroy
  has_many :projects, through: :plan_projects
  has_many :executions

  has_many :user_watching_plans, dependent: :destroy
  has_many :users, through: :user_watching_plans

  has_many :rounds

  validates :title, presence: true
  # validates :started_at, presence: true
  # validates :ended_at, presence: true

  scope :watched, ->(user) { joins(:users).where(users: { id: user }) }

  # capability
  def name
    title
  end

  def complete?
    state == TestSuiteState.enums.complete
  end

  def incomplete?
    !complete?
  end

  def complete
    state = self.state == TestSuiteState.enums.complete ? TestSuiteState.enums.incomplete : TestSuiteState.enums.complete
    self.update(state: state)
  end

  class << self

  def states
    TestSuiteState.enums.map{ |k,v| [I18n.t("test_suite_states.#{k}"),v] }
  end

  def state_names
    TestSuiteState.enums.map{ |k,v| [v, I18n.t("test_suite_states.#{k}")] }.to_h
  end

  end
end
