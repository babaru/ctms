class Label < ApplicationRecord
  belongs_to :project
  has_many :issue_labels
  has_many :issues, through: :issue_labels

  def is_requirement?
    !!is_requirement
  end


end
