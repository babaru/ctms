class AddIsDefectToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :is_defect, :boolean, default: false
  end
end
