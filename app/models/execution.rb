class Execution < ApplicationRecord
  belongs_to :scenario
  belongs_to :plan
  belongs_to :issue
  belongs_to :round

  scope :executed, ->(round, issue) { where(result: executed_results, round_id: round, scenario_id: Scenario.where(issue_id: issue).select(:id)) }

  def posted_to_gitlab?
    !!note_gitlab_id
  end

  def remarks?
    !!remarks
  end

  def add_remarks(content, access_token)
    issue_note = []
    issue_note << content
    issue_note << ">>>"
    issue_note << "[#{Execution.result_names[result]}] - #{scenario.title}"
    issue_note << scenario.body
    issue_note << ">>>"
    issue_note_content = issue_note.join("\r\n\r\n")

    update(remarks: content)
    GitLabAPI.instance.delete_note(
      scenario.project.gitlab_id,
      scenario.issue.gitlab_id,
      note_gitlab_id,
      access_token
    ) if posted_to_gitlab?

    data = GitLabAPI.instance.create_note(
      scenario.project.gitlab_id,
      scenario.issue.gitlab_id,
      issue_note_content,
      access_token
    )
    update(note_gitlab_id: data["id"])
  end

  def delete_remarks(access_token)
    GitLabAPI.instance.delete_note(
      scenario.project.gitlab_id,
      scenario.issue.gitlab_id,
      note_gitlab_id,
      access_token
    )
    update(remarks: nil, note_gitlab_id: nil)
  end

  class << self

  def find_or_create_by_round_and_scenario(round, scenario)
    where(scenario_id: scenario.id, round_id: round.id, issue_id: scenario.issue_id, plan_id: round.plan_id).first_or_create
  end

  def executed_results
    [ExecutionResult.enums.passed, ExecutionResult.enums.failed, ExecutionResult.enums.na]
  end

  def results
    ExecutionResult.enums.map{ |k,v| [I18n.t("execution_results.#{k}"),v] }
  end

  def result_names
    ExecutionResult.enums.map{ |k,v| [v, I18n.t("execution_results.#{k}")] }.to_h
  end

  end
end
