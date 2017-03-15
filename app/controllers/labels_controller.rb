class LabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_label, only: [:show, :edit, :update, :destroy, :mark_requirement]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:tab1, :tab2].freeze

  # GET /labels
  # GET /labels.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_label_params

    @conditions = []
    @conditions << Label.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_labels_grid(@conditions) }
      format.json { render json: Label.where(@conditions) }
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

  def build_query_label_params
    @query_label_params = Label.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_label_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_label_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:label])
      redirect_to labels_path(@query_params)
    end
  end

  # GET /labels/1
  # GET /labels/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  # GET /labels/new
  def new
    @label = Label.new
  end

  # GET /labels/1/edit
  def edit
  end

  # POST /labels
  # POST /labels.json
  def create
    @label = Label.new(label_params)

    respond_to do |format|
      if @label.save
        set_labels_grid
        format.html { redirect_to @label, notice: t('activerecord.success.messages.created', model: Label.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /labels/1
  # PATCH/PUT /labels/1.json
  def update
    respond_to do |format|
      if @label.update(label_params)
        set_labels_grid
        format.html { redirect_to @label, notice: t('activerecord.success.messages.updated', model: Label.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  def mark_requirement
    if request.post?
      respond_to do |format|
        @label.update(is_requirement: !@label.is_requirement?)
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: Label.model_name.human) }
      end
    end
  end

  # DELETE /labels/1
  # DELETE /labels/1.json
  def destroy
    @label.destroy

    respond_to do |format|
      set_labels_grid
      format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.destroyed', model: Label.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_label
    @label = Label.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def label_params
    params.require(:label).permit(
      :name,
      :color,
      :project_id,
      :is_requirement,
      )
  end

  def set_labels_grid(conditions = [])
    @labels_grid = LabelGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
