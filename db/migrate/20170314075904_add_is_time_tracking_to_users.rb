class AddIsTimeTrackingToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :under_time_tracking, :boolean, default: false
  end
end
