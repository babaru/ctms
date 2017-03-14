class TriggerController < ApplicationController
  def index
    logger.info request.body
    respond_to do |format|
      format.json { render nothing: true }
    end
  end
end
