class AddNamespaceToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :namespace, :string
  end
end
