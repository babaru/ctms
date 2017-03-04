class Scenario < ApplicationRecord
  def title
    "#{id.to_s.rjust(3, '0')} - #{name}"
  end
end
