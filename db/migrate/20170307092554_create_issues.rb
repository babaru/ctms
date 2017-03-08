class CreateIssues < ActiveRecord::Migration[5.0]
  def change
    create_table :issues do |t|
      t.references :project, foreign_key: true
      t.string :name
      t.text :body
      t.string :gitlab_id
      t.boolean :is_existing_on_gitlab, default: false
      t.references :milestone, foreign_key: true
      t.string :labels

      t.timestamps
    end
  end
end
