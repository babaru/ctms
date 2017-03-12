class CreateUserWatchingPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :user_watching_plans do |t|
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
