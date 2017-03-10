class CreateLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :labels do |t|
      t.string :name
      t.string :color
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
