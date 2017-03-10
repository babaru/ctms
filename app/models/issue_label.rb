class IssueLabel < ApplicationRecord
  belongs_to :label
  belongs_to :issue
end
