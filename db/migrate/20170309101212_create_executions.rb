class CreateExecutions < ActiveRecord::Migration[5.0]
  def change
    create_table :executions do |t|
      t.references :scenario, foreign_key: true
      t.references :plan, foreign_key: true
      t.integer :result, default: 0
      t.text :remarks

      t.timestamps
    end
  end
end
