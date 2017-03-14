class TriggerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery prepend: true, with: :exception

  def index
    object_kind = params[:object_kind]
    case object_kind
    when 'note'
    when 'issue'
      # issue = Issue.find_by_gitlab_id(params[:object_attributes][:id])
      # issue.update()
    when 'project'
    end

    respond_to do |format|
      format.json { head :ok }
    end
  end
end
