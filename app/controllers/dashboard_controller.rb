class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @dashboard_plans_grid = DashboardPlanGrid.new do |scope|
      scope.page(params[:page]).joins(:users).where(users: { id: current_user} ).per(20)
    end

    @dashboard_projects_grid = DashboardProjectGrid.new do |scope|
      scope.page(params[:page]).joins(:users).where(users: { id: current_user} ).per(20)
    end
  end
end
