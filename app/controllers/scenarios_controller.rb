

class ScenariosController < ApplicationController
  before_action :set_scenario, only: [:show, :edit, :update, :destroy]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:summary].freeze

  # GET /scenarios
  # GET /scenarios.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_scenario_params

    @conditions = []
    @conditions << Scenario.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_scenarios_grid(@conditions) }
      format.json { render json: Scenario.where(@conditions) }
    end
  end

  def build_query_params(parameters)
    QUERY_KEYS.each do |key|
      if parameters[key].is_a?(Array)
        @query_params[key] = "a_#{parameters[key].join(ARRAY_SP)}"
      else
        @query_params[key] = parameters[key] if parameters[key] && !parameters[key].empty?
      end
    end
  end

  def build_query_scenario_params
    @query_scenario_params = Scenario.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_scenario_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_scenario_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:scenario])
      redirect_to scenarios_path(@query_params)
    end
  end

  # GET /scenarios/1
  # GET /scenarios/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  # GET /scenarios/new
  def new
    issue = Issue.find(params[:issue_id])
    @scenario = Scenario.new(issue_id: params[:issue_id], project_id: issue.project_id)
  end

  # GET /scenarios/1/edit
  def edit
  end

  def execute
    if request.post?
      logger.debug params.keys
      scenario_id = params[:id]
      plan_id = params[:plan_id]
      result = params[:result]

      response_params = {}
      response_params[:issue_id] = params[:issue_id] if params[:issue_id]
      response_params[:tab] = params[:tab] if params[:tab]
      response_params[:page] = params[:page] if params[:page]

      @scenario = Scenario.find(scenario_id)
      execution = @scenario.execution(plan_id) || Execution.create(scenario_id: scenario_id, plan_id: plan_id)
      execution.update(result: result)

      respond_to do |format|
        format.html { redirect_to plan_path(params[:plan_id], response_params), notice: t('activerecord.success.messages.updated', model: Scenario.model_name.human) }
      end
    end
  end

  # POST /scenarios
  # POST /scenarios.json
  def create
    @scenario = Scenario.new(scenario_params)

    respond_to do |format|
      if @scenario.save
        # set_scenarios_grid
        format.html { redirect_to project_path(@scenario.project_id, issue_id: @scenario.issue_id), notice: t('activerecord.success.messages.created', model: Scenario.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /scenarios/1
  # PATCH/PUT /scenarios/1.json
  def update
    respond_to do |format|
      if @scenario.update(scenario_params)
        # set_scenarios_grid
        format.html { redirect_to project_path(@scenario.project_id, issue_id: @scenario.issue_id), notice: t('activerecord.success.messages.updated', model: Scenario.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /scenarios/1
  # DELETE /scenarios/1.json
  def destroy
    issue_id = @scenario.issue_id
    project_id = @scenario.project_id
    @scenario.destroy

    respond_to do |format|
      set_scenarios_grid
      format.html { redirect_to project_path(project_id, issue_id: issue_id), notice: t('activerecord.success.messages.destroyed', model: Scenario.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_scenario
    @scenario = Scenario.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def scenario_params
    params.require(:scenario).permit(
      :name,
      :body,
      :project_id,
      :issue_id
      )
  end

  def set_scenarios_grid(conditions = [])
    @scenarios_grid = ScenarioGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
