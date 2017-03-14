class CreateTimeSheets < ActiveRecord::Migration[5.0]
  def change
    create_table :time_sheets do |t|
      t.references :user, foreign_key: true
      t.references :issue, foreign_key: true
      t.references :project, foreign_key: true
      t.integer :spent
      t.datetime :spent_at

      t.timestamps
    end
  end
end
