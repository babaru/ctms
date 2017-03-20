class AddBodyToPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :plans, :body, :text
  end
end
