class AddAssigneeReferencesToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :assignee_id, :integer
    add_index :issues, :assignee_id
    add_foreign_key :issues, :users, column: :assignee_id
  end
end
