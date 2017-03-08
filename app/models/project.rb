class Project < ApplicationRecord
  has_many :issues
  has_many :milestone

  validates :name, presence: true, uniqueness: true

  def title
    name
  end
end
