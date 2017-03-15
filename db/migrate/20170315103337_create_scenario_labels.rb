class CreateScenarioLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :scenario_labels do |t|
      t.references :scenario, foreign_key: true
      t.references :label, foreign_key: true

      t.timestamps
    end
  end
end
