class Round < ApplicationRecord
  belongs_to :plan
  has_many :executions, dependent: :destroy

  scope :by_project, ->(project) { joins(:plan).where(plans: { id: Plan.by_project(project).select(:id).distinct }) }

  def projects
    plan.projects
  end

  def complete?
    state == TestSuiteState.enums.complete
  end

  def incomplete?
    !complete?
  end

  def total_scenarios_count
    projects.inject(0) {|sum, project| sum += project.scenarios.count }
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
