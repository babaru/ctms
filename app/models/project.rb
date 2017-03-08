class Project < ApplicationRecord
  has_many :issues
  has_many :milestone
  has_many :scenarios

  validates :name, presence: true, uniqueness: true

  def title
    name
  end
end
