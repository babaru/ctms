class ScenarioLabel < ApplicationRecord
  belongs_to :scenario
  belongs_to :label
end
