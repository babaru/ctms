class ChangePathNameOfProjects < ActiveRecord::Migration[5.0]
  def change
    rename_column :projects, :path, :path_with_namespace
  end
end
