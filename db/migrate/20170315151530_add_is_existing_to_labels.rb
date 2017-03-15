class AddIsExistingToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :is_existing_on_gitlab, :boolean, default: false
  end
end
