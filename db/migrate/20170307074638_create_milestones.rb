class CreateMilestones < ActiveRecord::Migration[5.0]
  def change
    create_table :milestones do |t|
      t.string :name
      t.string :description
      t.references :project, foreign_key: true
      t.string :gitlab_id
      t.boolean :is_existing_on_gitlab, default: false

      t.timestamps
    end
  end
end
