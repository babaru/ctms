class CreateRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :rounds do |t|
      t.string :title
      t.datetime :started_at
      t.datetime :ended_at
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
