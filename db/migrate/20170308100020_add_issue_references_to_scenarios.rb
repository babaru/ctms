class AddIssueReferencesToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_reference :scenarios, :issue, foreign_key: true
  end
end
