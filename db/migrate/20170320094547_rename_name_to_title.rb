class RenameNameToTitle < ActiveRecord::Migration[5.0]
  def up
    rename_column :scenarios, :name, :title
    rename_column :plans, :name, :title
  end

  def down
    rename_column :scenarios, :title, :name
    rename_column :plans, :title, :name
  end
end
