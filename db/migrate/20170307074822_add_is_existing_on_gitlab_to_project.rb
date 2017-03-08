class AddIsExistingOnGitlabToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :is_existing_on_gitlab, :boolean, default: false
  end
end
