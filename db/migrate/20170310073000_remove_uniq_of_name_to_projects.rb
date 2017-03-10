class RemoveUniqOfNameToProjects < ActiveRecord::Migration[5.0]
  def change
    remove_index :projects, :name
  end
end
