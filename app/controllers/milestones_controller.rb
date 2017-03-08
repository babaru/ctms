

class MilestonesController < ApplicationController
  before_action :set_milestone, only: [:show, :edit, :update, :destroy]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:tab1, :tab2].freeze

  # GET /milestones
  # GET /milestones.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_milestone_params

    @conditions = []
    @conditions << Milestone.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_milestones_grid(@conditions) }
      format.json { render json: Milestone.where(@conditions) }
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

  def build_query_milestone_params
    @query_milestone_params = Milestone.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_milestone_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_milestone_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:milestone])
      redirect_to milestones_path(@query_params)
    end
  end

  # GET /milestones/1
  # GET /milestones/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  # GET /milestones/new
  def new
    @milestone = Milestone.new
  end

  # GET /milestones/1/edit
  def edit
  end

  # POST /milestones
  # POST /milestones.json
  def create
    @milestone = Milestone.new(milestone_params)

    respond_to do |format|
      if @milestone.save
        set_milestones_grid
        format.html { redirect_to @milestone, notice: t('activerecord.success.messages.created', model: Milestone.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /milestones/1
  # PATCH/PUT /milestones/1.json
  def update
    respond_to do |format|
      if @milestone.update(milestone_params)
        set_milestones_grid
        format.html { redirect_to @milestone, notice: t('activerecord.success.messages.updated', model: Milestone.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /milestones/1
  # DELETE /milestones/1.json
  def destroy
    @milestone.destroy

    respond_to do |format|
      set_milestones_grid
      format.html { redirect_to milestones_url, notice: t('activerecord.success.messages.destroyed', model: Milestone.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_milestone
    @milestone = Milestone.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def milestone_params
    params.require(:milestone).permit(
      :name,
      :description,
      :project_id,
      :gitlab_id,
      :is_existing_on_gitlab,
      )
  end

  def set_milestones_grid(conditions = [])
    @milestones_grid = MilestoneGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end


