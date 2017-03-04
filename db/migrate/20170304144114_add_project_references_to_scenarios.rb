class AddProjectReferencesToScenarios < ActiveRecord::Migration[5.0]
  def change
    add_reference :scenarios, :project, foreign_key: true
  end
end
