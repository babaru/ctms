class ExecutionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_execution, only: [:show, :edit, :update, :destroy, :remarks, :post_remarks, :delete_remarks, :execute]
  before_action :set_redirect_url_from_session, only: [:new, :edit, :remarks]
  before_action :get_redirect_url_from_session, only: [:create, :update, :post_remarks]
  before_action :get_redirect_url_from_params, only: [:destroy, :delete_remarks, :execute]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:tab1, :tab2].freeze

  # GET /executions
  # GET /executions.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_execution_params

    @conditions = []
    @conditions << Execution.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_executions_grid(@conditions) }
      format.json { render json: Execution.where(@conditions) }
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

  def build_query_execution_params
    @query_execution_params = Execution.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_execution_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_execution_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:execution])
      redirect_to executions_path(@query_params)
    end
  end

  # GET /executions/1
  # GET /executions/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  def remarks
    respond_to do |format|
      format.js
    end
  end

  def post_remarks
    if request.post?
      respond_to do |format|
        if @execution.add_remarks(execution_params[:remarks], current_user.access_token)
          format.js
        else
          format.js { render :remarks }
        end
      end
    end
  end

  def delete_remarks
    if request.post?
      respond_to do |format|
        @execution.delete_remarks(current_user.access_token)
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Execution.model_name.human) }
      end
    end
  end

  def execute
    if request.post?
      @execution.update(result: params[:result])
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Execution.model_name.human) }
      end
    end
  end

  # GET /executions/new
  def new
    @execution = Execution.new
  end

  # GET /executions/1/edit
  def edit
  end

  # POST /executions
  # POST /executions.json
  def create
    @execution = Execution.new(execution_params)

    respond_to do |format|
      if @execution.save
        set_executions_grid
        format.html { redirect_to @execution, notice: t('activerecord.success.messages.created', model: Execution.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /executions/1
  # PATCH/PUT /executions/1.json
  def update
    respond_to do |format|
      if @execution.update(execution_params)
        set_executions_grid
        format.html { redirect_to @execution, notice: t('activerecord.success.messages.updated', model: Execution.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /executions/1
  # DELETE /executions/1.json
  def destroy
    @execution.destroy

    respond_to do |format|
      set_executions_grid
      format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.destroyed', model: Execution.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_execution
    @execution = Execution.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def execution_params
    params.require(:execution).permit(
      :scenario_id,
      :plan_id,
      :result,
      :remarks,
      )
  end

  def set_executions_grid(conditions = [])
    @executions_grid = ExecutionGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
