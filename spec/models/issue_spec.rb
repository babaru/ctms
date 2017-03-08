require 'rails_helper'

RSpec.describe Issue, type: :model do
  before do
    @api = double('GitLabAPI')
  end

  describe '#sync_from_gitlab' do
    it 'create instances if new data received' do
      expect(@api).to receive(:issues).with(2).once.and_return([{"id" => 20, "iid" => 21, "project_id" => 2, "title" => "title", "description" => 'body'}])
      expect(@api).to receive(:issues).with(2, 2).once.and_return([])
      expect(@api).to receive(:total_pages).with(anything).and_return(2)
      Issue.sync_from_gitlab(2, @api)
      issue = Issue.find_by_gitlab_id(20)
      expect(issue).not_to be_nil
      expect(issue.gitlab_id).to eq("20")
      expect(issue.gitlab_iid).to eq("21")
      expect(issue.name).to eq("title")
      expect(issue.body).to eq("body")
    end
  end
end
