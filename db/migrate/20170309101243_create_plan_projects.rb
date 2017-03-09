class CreatePlanProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :plan_projects do |t|
      t.references :plan, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
