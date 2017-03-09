class ChangeMilestoneDescription < ActiveRecord::Migration[5.0]
  def change
    change_column :milestones, :description, :text
  end
end
