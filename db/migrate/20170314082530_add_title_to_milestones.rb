class AddTitleToMilestones < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :title, :string
  end
end
