class RemoveNameColumnMilestones < ActiveRecord::Migration[5.0]
  def change
    remove_column :milestones, :name
  end
end
