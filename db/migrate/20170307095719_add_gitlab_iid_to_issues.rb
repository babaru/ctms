class AddGitlabIidToIssues < ActiveRecord::Migration[5.0]
  def change
    add_column :issues, :gitlab_iid, :string
  end
end
