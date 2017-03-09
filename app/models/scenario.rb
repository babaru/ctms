class Scenario < ApplicationRecord
  belongs_to :project
  belongs_to :issue
  
  def title
    "#{id.to_s.rjust(3, '0')} - #{name}"
  end
end
