class TriggerController < ApplicationController
  def index
    logger.info request.body
  end
end
