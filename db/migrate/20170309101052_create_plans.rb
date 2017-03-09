class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :name
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :state, default: 0
      t.text :remarks

      t.timestamps
    end
  end
end
