class Milestone < ApplicationRecord
  belongs_to :project, optional: true
end
