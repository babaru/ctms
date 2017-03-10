class AddIsRequirementToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :is_requirement, :boolean, default: false
  end
end
