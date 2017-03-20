class AddRoundReferencesAndIssueReferencesToExecutions < ActiveRecord::Migration[5.0]
  def up
    add_reference :executions, :round, foreign_key: true
    add_reference :executions, :issue, foreign_key: true

    Execution.all.each do |execution|
      execution.issue_id = execution.scenario.issue_id
      execution.round_id = Round.where(plan: execution.plan).first_or_create(title: "#{execution.plan.name} - Round #1", plan_id: execution.plan_id) do |round|
        round.started_at = Time.current
        round.ended_at = Time.current
      end.id
      execution.save
    end
  end

  def down
    remove_reference :executions, :round, foreign_key: true
    remove_reference :executions, :issue, foreign_key: true
  end
end
