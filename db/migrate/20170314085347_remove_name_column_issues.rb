class RemoveNameColumnIssues < ActiveRecord::Migration[5.0]
  def change
    remove_column :issues, :name
  end
end
