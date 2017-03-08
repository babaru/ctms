class AddGitlabIidToMilestones < ActiveRecord::Migration[5.0]
  def change
    add_column :milestones, :gitlab_iid, :string
  end
end
