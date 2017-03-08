require 'rails_helper'

RSpec.describe GitLabAPI do
  before :each do
    @rest_client = double(:rest_client)
    @api = GitLabAPI.new(@rest_client, 'PRIVATE-TOKEN')
  end
  
  describe '#project_by_name' do
    it 'returns project data' do
      project_namespace = 'ei6'
      project_name = 'doc'
      project_id = 122
      name_with_namespace = "#{project_namespace}/#{project_name}"

      expect(@rest_client).to receive(:get).with("/projects/#{CGI.escape(name_with_namespace)}", anything).and_return({"id"=>project_id, "name"=>project_name})
      data = @api.project_by_name(name_with_namespace)
      expect(data["id"]).to eq(122)
      expect(data["name"]).to eq(project_name)
    end
  end

  describe '#projects' do
    it 'returns all projects' do
      expect(@rest_client).to receive(:get).with("/projects?per_page=100&page=1", anything).and_return([{"id"=>1, "name"=>'project1'}, {"id"=>2, "name"=>'project2'}, {"id"=>3, "name"=>'project3'}])

      data = @api.projects
      expect(data.length).to eq(3)
    end

    # it 'return pages' do
    #   resp = GitLabAPI.instance.projects
    #   puts resp.headers["X-Total-Pages"]
    # end
  end

  describe '#issues' do
    it 'return all issues of a project' do
      # puts GitLabAPI.instance.issues(156)
    end
  end
end
