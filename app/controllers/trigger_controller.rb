class TriggerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery prepend: true, with: :exception

  def index
    logger.info request.body
    respond_to do |format|
      format.json { head :ok }
    end
  end
end
