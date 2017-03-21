class AddScenarioToIssues < ActiveRecord::Migration[5.0]
  def change
    add_reference :issues, :scenario, foreign_key: true
  end
end
