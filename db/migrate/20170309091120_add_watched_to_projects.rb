class AddWatchedToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :is_watched, :boolean, default: false
  end
end
