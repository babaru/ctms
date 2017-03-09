class PlanProject < ApplicationRecord
  belongs_to :plan
  belongs_to :project
end
