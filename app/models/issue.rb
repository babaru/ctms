class Issue < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :milestone, optional: true
  belongs_to :user, optional: true
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id, optional: true
  has_many :scenarios
  has_many :issue_labels
  has_many :labels, through: :issue_labels
  has_many :time_sheets

  scope :no_label, -> { where.not(id: Issue.has_label.select(:id).distinct) }
  scope :has_label, -> {
    joins(:labels).where({
      labels: {
          id: Label.select(:id)
        }
    }).distinct
  }
  scope :requirements, -> { joins(:labels).where(labels: { is_requirement: true }).distinct }
  scope :label, ->(label) { joins(:labels).where(labels: { id: label }).distinct }

  def list_title
    "##{gitlab_id} - #{title}"
  end

  def list_title_with_progress(plan)
    return list_title if scenarios.count == 0
    "#{list_title} (#{Execution.executed(plan, id).count}/#{scenarios.count})"
  end

  def opened?
    state == 'opened'
  end

  def html_description
    Kramdown::Document.new(description).to_html.html_safe
  end

  def self.sync_from_gitlab(project, api = nil)
    api ||= GitLabAPI.instance
    project.issues.update(is_existing_on_gitlab: false)
    collection_data = api.issues(project.gitlab_id)
    total_pages = api.total_pages(collection_data).to_i

    1.upto(total_pages) do |page|
      collection_data.each do |data|
        from_gitlab_data(project, data)
      end
      collection_data = api.issues(project.gitlab_id, page + 1) if page < total_pages
    end
  end

  def self.from_gitlab_data(project, data)
    return nil unless data
    milestone = Milestone.from_gitlab_data(project, data["milestone"])
    labels = Label.from_gitlab_data(project, data["labels"])
    user = User.from_gitlab_data(data["author"])
    assignee = User.from_gitlab_data(data["assignee"])
    
    issue = where(gitlab_id: data["id"]).first_or_create
    data_attrs = {}
    data_attrs[:description] = fix_image_url(project, data["description"]) if data["description"]
    %w(title state created_at updated_at).each do |str|
      data_attrs[str.to_sym] = data[str] if data[str]
    end
    data_attrs[:gitlab_iid] = data["iid"]
    data_attrs[:is_existing_on_gitlab] = true
    data_attrs[:project] = project
    data_attrs[:milestone] = milestone
    data_attrs[:labels] = labels
    data_attrs[:user] = user
    data_attrs[:assignee] = assignee
    issue.update(data_attrs)
    issue
  end

  def self.fix_image_url(project, description)
    temp_content = description
    /\<img\ssrc\=\"(\/[\/a-zA-Z0-9\.]+)\"\s.*\/\>/.match(description) do |matches|
      matches.captures.each do |m|
        new_url = "#{Settings.gitlab.web.base_uri}/#{project.path_with_namespace}#{m}"
        logger.debug "matched: #{m} and replaced by #{new_url}"
        temp_content = temp_content.gsub("#{m}", new_url)
      end if matches
    end
    temp_content
  end
end
