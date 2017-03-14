class Issue < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :milestone, optional: true
  has_many :scenarios
  has_many :issue_labels
  has_many :labels, through: :issue_labels

  # scope :labels, -> { |labels| where(label_ids.include?}

  def nav_title
    scenarios_count = scenarios.count > 0 ? " [#{scenarios.count}]" : ''
    "#{name}#{scenarios_count}"
  end

  def self.sync_from_gitlab(project, api)
    api ||= GitLabAPI.instance
    project.issues.update(is_existing_on_gitlab: false)
    collection_data = api.issues(project.gitlab_id)
    total_pages = api.total_pages(collection_data).to_i

    1.upto(total_pages) do |page|
      collection_data.each do |data|
        milestone = Milestone.from_gitlab_data(project, data["milestone"])
        labels = Label.from_gitlab_data(project, data["labels"])
        from_gitlab_data(project, milestone, labels, data)
      end
      collection_data = api.issues(project.gitlab_id, page + 1) if page < total_pages
    end
  end

  def self.from_gitlab_data(project, milestone, labels, data)
    issue = where(gitlab_id: data["id"]).first_or_create
    data_attrs = {}
    %w(title description state).each do |str|
      data_attrs[str.to_sym] = data[str] if data[str]
    end
    data_attrs[:gitlab_iid] = data["iid"]
    data_attrs[:is_existing_on_gitlab] = true
    data_attrs[:project] = project
    data_attrs[:milestone] = milestone
    data_attrs[:labels] = labels
    issue.update(data_attrs)
    issue
  end
end
