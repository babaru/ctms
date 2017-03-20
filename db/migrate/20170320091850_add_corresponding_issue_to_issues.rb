class AddCorrespondingIssueToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :corrsponding_issue_id, :integer
    add_index :issues, :corrsponding_issue_id
    add_foreign_key :issues, :issues, column: :corrsponding_issue_id
  end
end
