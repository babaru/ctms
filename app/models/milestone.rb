class Milestone < ApplicationRecord
  belongs_to :project, optional: true

  def title
    name
  end
end
