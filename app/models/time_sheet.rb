class TimeSheet < ApplicationRecord
  belongs_to :user
  belongs_to :issue
  belongs_to :project
end
