class AddCorrespondingIssueToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :corresponding_issue_id, :integer
    add_index :issues, :corresponding_issue_id
    add_foreign_key :issues, :issues, column: :corresponding_issue_id
  end
end
