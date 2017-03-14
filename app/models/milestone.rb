class Milestone < ApplicationRecord
  belongs_to :project, optional: true

  def self.from_gitlab_data(project, data)
    return nil unless data
    milestone = where(gitlab_id: data["id"]).first_or_create
    data_attrs = {}
    %w(title description).each do |str|
      data_attrs[str.to_sym] = data[str] if data[str]
    end
    data_attrs[:gitlab_iid] = data["iid"]
    data_attrs[:is_existing_on_gitlab] = true
    data_attrs[:project_id] = project
    milestone.update(data_attrs)
    milestone
  end
end
