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

end
