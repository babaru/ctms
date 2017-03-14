class AddNoteGitlabIdToExecutions < ActiveRecord::Migration[5.0]
  def change
    add_column :executions, :note_gitlab_id, :string
  end
end
