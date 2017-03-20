class AddTypeToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :type, :string, default: 'Issue'
  end
end
