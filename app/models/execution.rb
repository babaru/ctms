class Execution < ApplicationRecord
  belongs_to :scenario
  belongs_to :plan
end
