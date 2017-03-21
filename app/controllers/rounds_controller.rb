

class RoundsController < ApplicationController
  before_action :set_round, only: [:show, :edit, :update, :complete, :destroy]

  QUERY_KEYS = [:title].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  SHOW_TABS = [].freeze

  # GET /rounds
  # GET /rounds.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_round_params

    @conditions = []
    @conditions << Round.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_rounds_grid(@conditions) }
      format.json { render json: Round.where(@conditions) }
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

  def build_query_round_params
    @query_round_params = Round.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_round_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_round_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:round])
      redirect_to rounds_path(@query_params)
    end
  end

  # GET /rounds/1
  # GET /rounds/1.json
  def show
    @project = Project.find params[:project_id] if params[:project_id]
    @project ||= @round.projects.first
    @issue = Issue.find params[:issue_id] if params[:issue_id]
    @scenario = Scenario.find params[:scenario_id] if params[:scenario_id]

    @label = Label.find params[:label_id] if params[:label_id]
    @no_label = params[:no_label]
    @unexecuted = params[:unexecuted]
    @execution_result = params[:execution_result]

    conditions = {}
    conditions[:issue_id] = @issue.id if @issue

    @scenario_folders = @project.requirements

    @scenarios_grid = ScenarioGrid.new do |scope|
      r = scope.where(conditions)
      r = r.label(@label) if @label
      r = r.no_label if @no_label
      r = r.unexecuted(@round) if @unexecuted
      r = r.execution_result(@round, @execution_result) if @execution_result
      r.page(params[:page]).per(20)
    end
    @scenarios_grid.column_names = [:execution_title, :labels, "execution_buttons project-actions"]

    @defects = Defect.current_scenario(@scenario) if @scenario
  end

  # GET /rounds/new
  def new
    @round = Round.new
    @round.plan_id = params[:plan_id]
    @redirect_url = params[:redirect_url]
    session[:redirect_url] = params[:redirect_url]
  end

  # GET /rounds/1/edit
  def edit
    @redirect_url = params[:redirect_url]
    session[:redirect_url] = params[:redirect_url]
  end

  # POST /rounds
  # POST /rounds.json
  def create
    @redirect_url = session[:redirect_url]
    session[:redirect_url] = nil

    @round = Round.new(round_params)

    respond_to do |format|
      if @round.save
        set_rounds_grid
        format.html { redirect_to @redirect_url, notice: t('activerecord.success.messages.created', model: Round.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /rounds/1
  # PATCH/PUT /rounds/1.json
  def update
    @redirect_url = session[:redirect_url]
    session[:redirect_url] = nil

    respond_to do |format|
      if @round.update(round_params)
        set_rounds_grid
        format.html { redirect_to @redirect_url, notice: t('activerecord.success.messages.updated', model: Round.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  def complete
    if request.post?
      respond_to do |format|
        @round.complete
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: Round.model_name.human) }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.json
  def destroy
    @round.destroy

    respond_to do |format|
      set_rounds_grid
      format.html { redirect_to rounds_url, notice: t('activerecord.success.messages.destroyed', model: Round.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_round
    @round = Round.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def round_params
    params.require(:round).permit(
      :title,
      :started_at,
      :ended_at,
      :plan_id,
      :scenario_id,
      :project_id,
      :issue_id
      )
  end

  def set_rounds_grid(conditions = [])
    @rounds_grid = RoundGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
