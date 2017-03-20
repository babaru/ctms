class PlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :complete, :watch]

  QUERY_KEYS = [:title].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  SHOW_TABS = [:rounds, :summary].freeze
  LIST_TABS = [:watched, :all].freeze

  # GET /plans
  # GET /plans.json
  def index
    @list_tabs = LIST_TABS
    @current_tab = params[:tab]
    @current_tab ||= LIST_TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :all
      @query_params = {}
      build_query_params(params)
      build_query_plan_params

      @conditions = []
      @conditions << Plan.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

      if @conditions.length > 0
        conditions = @conditions[0]
        @conditions.each_with_index do |item, index|
          conditions = conditions.or(item) if index > 0
        end
        @conditions = conditions
      end

      respond_to do |format|
        format.html { set_plans_grid(@conditions) }
        format.json { render json: Plan.where(@conditions) }
      end
    when :watched
      @plans_grid = PlanGrid.new do |scope|
        scope.page(params[:page]).joins(:users).where(users: {:id => current_user.id }).per(20)
      end
      respond_to do |format|
        format.html
      end
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

  def build_query_plan_params
    @query_plan_params = Plan.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_plan_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_plan_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:plan])
      redirect_to plans_path(@query_params)
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    @tabs = SHOW_TABS
    @current_tab = params[:tab]
    @current_tab ||= SHOW_TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :summary
      
    when :rounds
      @rounds_grid = RoundGrid.new do |scope|
        scope.where(plan_id: @plan).page(params[:page]).per(20)
      end
    end
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    @redirect_url = params[:redirect_url]
    session[:redirect_url] = params[:redirect_url]
  end

  # GET /plans/1/edit
  def edit
    @redirect_url = params[:redirect_url]
    session[:redirect_url] = params[:redirect_url]
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = Plan.new(plan_params)
    @redirect_url = session[:redirect_url]
    session[:redirect_url] = nil

    respond_to do |format|
      if @plan.save
        set_plans_grid
        format.html { redirect_to @redirect_url, notice: t('activerecord.success.messages.created', model: Plan.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    @redirect_url = session[:redirect_url]
    session[:redirect_url] = nil

    respond_to do |format|
      if @plan.update(plan_params)
        set_plans_grid
        format.html { redirect_to @redirect_url, notice: t('activerecord.success.messages.updated', model: Plan.model_name.human) }
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
        @plan.complete
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: Plan.model_name.human) }
      end
    end
  end

  def watch
    if request.post?
      respond_to do |format|
        @plan.watch(current_user)
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: Plan.model_name.human) }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    @plan.destroy
    redirect_url = params[:redirect_url]

    respond_to do |format|
      set_plans_grid
      format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.destroyed', model: Plan.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_plan
    @plan = Plan.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def plan_params
    params.require(:plan).permit(
      :title,
      :started_at,
      :ended_at,
      :state,
      :remarks,
      :project_ids => [],
      )
  end

  def set_plans_grid(conditions = [])
    @plans_grid = PlanGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
