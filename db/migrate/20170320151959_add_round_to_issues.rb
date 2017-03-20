class AddRoundToIssues < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :round, foreign_key: true
  end
end
