class CreateIssueLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :issue_labels do |t|
      t.references :label, foreign_key: true
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
