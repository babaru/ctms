require 'rest_client'

class GitLabAPI
  attr_reader :rest_client, :private_token

  def self.instance
    GitLabAPI.new(RestClient.new(Settings.gitlab.api.base_uri), Settings.gitlab.api.private_token)
  end

  def total_pages(response)
    return response.headers["X-Total-Pages"]
  end

  def initialize(rest_client, private_token)
    @private_token = private_token
    @rest_client = rest_client
  end

  def default_options
    { verify: false, headers: { "PRIVATE-TOKEN" => private_token } }
  end

  def project_by_name(name)
    name = CGI.escape(name)
    rest_client.get("/projects/#{name}", default_options)
  end

  def projects(page = 1, per_page = 100)
    rest_client.get("/projects?per_page=#{per_page}&page=#{page}", default_options)
  end

  def issues(project_id, page = 1, per_page = 100)
    rest_client.get("/projects/#{project_id}/issues?per_page=#{per_page}&page=#{page}", default_options)
  end

  def create_issue(project_id, title, description, milestone, labels, access_token)
    rest_client.post("/projects/#{project_id}/issues", { verify: false, body: { title: title, description: description, milestone: milestone, labels: labels, access_token: access_token } })
  end

  # Create a note for an issue
  def create_note(project_id, issue_id, content, access_token)
    rest_client.post("/projects/#{project_id}/issues/#{issue_id}/notes", { verify: false, body: { body: content, access_token: access_token } })
  end

  # Modify a note for an issue
  def modify_note(project_id, issue_id, note_id, content, access_token)
    rest_client.put("/projects/#{project_id}/issues/#{issue_id}/notes/#{note_id}", { verify: false, body: { body: content, access_token: access_token } })
  end

  def delete_note(project_id, issue_id, note_id, access_token)
    rest_client.delete("/projects/#{project_id}/issues/#{issue_id}/notes/#{note_id}", { verify: false, body: { access_token: access_token } })
  end

  def notes(project_id, issue_id, page = 1, per_page = 100)
    rest_client.get("/projects/#{project_id}/issues/#{issue_id}/notes?per_page=#{per_page}&page=#{page}", default_options)
  end

end
