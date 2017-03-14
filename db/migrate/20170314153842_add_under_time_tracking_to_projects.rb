class AddUnderTimeTrackingToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :under_time_tracking, :boolean, default: false
  end
end
