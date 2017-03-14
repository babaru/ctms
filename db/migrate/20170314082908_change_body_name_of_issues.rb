class ChangeBodyNameOfIssues < ActiveRecord::Migration[5.0]
  def change
    rename_column :issues, :body, :description
  end
end
