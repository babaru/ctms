class Label < ApplicationRecord
  belongs_to :project
  has_many :issue_labels
  has_many :issues, through: :issue_labels

  scope :requirements, -> { where(is_requirement: true) }

  def is_requirement?
    !!is_requirement
  end
end
