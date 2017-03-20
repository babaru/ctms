class AddStateAndRemarksToRounds < ActiveRecord::Migration[5.0]
  def change
    add_column :rounds, :state, :integer, default: 0
    add_column :rounds, :remarks, :text
  end
end
