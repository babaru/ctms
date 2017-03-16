class Execution < ApplicationRecord
  belongs_to :scenario
  belongs_to :plan

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

  def results
    ExecutionResult.enums.map{ |k,v| [I18n.t("execution_results.#{k}"),v] }
  end

  def result_names
    ExecutionResult.enums.map{ |k,v| [v, I18n.t("execution_results.#{k}")] }.to_h
  end

  end
end
