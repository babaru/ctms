class RemoveLabelsFromIssues < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :labels
  end
end
