class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: [:show, :edit, :update, :destroy, :sync_time_sheets_from_gitlab]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:scenarios].freeze

  # GET /issues
  # GET /issues.json
  def index
    @query_params = {}
    build_query_params(params)
    build_query_issue_params

    @conditions = []
    @conditions << Issue.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

    if @conditions.length > 0
      conditions = @conditions[0]
      @conditions.each_with_index do |item, index|
        conditions = conditions.or(item) if index > 0
      end
      @conditions = conditions
    end

    respond_to do |format|
      format.html { set_issues_grid(@conditions) }
      format.json { render json: Issue.where(@conditions) }
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

  def build_query_issue_params
    @query_issue_params = Issue.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_issue_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_issue_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:issue])
      redirect_to issues_path(@query_params)
    end
  end

  def sync_from_gitlab
    if request.post?
      project = Project.find(params[:project_id])
      Issue.sync_from_gitlab(project, GitLabAPI.instance)

      respond_to do |format|
        format.html { redirect_to project_path(project) }
        format.js
      end
    end
  end

  def sync_time_sheets_from_gitlab
    if request.post?
      TimeSheet.sync_from_gitlab_by_issue(@issue)

      respond_to do |format|
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: TimeSheet.model_name.human) }
        format.js
      end
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :scenarios
      @current_label = Label.find(params[:label_id]) if params[:label_id]
      @no_label = params[:no_label]
      @scenarios_grid = ScenarioGrid.new do |scope|
        if @current_label
          scope.page(params[:page]).joins(:labels).where(issue: @issue, labels: { id: @current_label.id }).per(20)
        elsif @no_label
          scenario_with_labels_ids = Scenario.joins(:labels).where(issue: @issue, labels: { id: Label.used_by_scenarios(@issue.project_id).select(:id).distinct }).select(:id).distinct
          scope.page(params[:page]).where(issue: @issue).where.not(id: scenario_with_labels_ids).per(20)
        else
          scope.page(params[:page]).where(issue: @issue).per(20)
        end
      end
      @scenarios_grid.column_names = [:scenario_title, :labels, "crud_buttons project-actions"]
    end
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @redirect_url = params[:redirect_url].html_safe
  end

  # GET /issues/1/edit
  def edit
    @redirect_url = params[:redirect_url].html_safe
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @redirect_url = params[:redirect_url].html_safe

    respond_to do |format|
      if @issue.save
        set_issues_grid
        format.html { redirect_to @issue, notice: t('activerecord.success.messages.created', model: Issue.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    @redirect_url = params[:redirect_url].html_safe
    respond_to do |format|
      if @issue.update(issue_params)
        set_issues_grid
        format.html { redirect_to @issue, notice: t('activerecord.success.messages.updated', model: Issue.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @redirect_url = params[:redirect_url].html_safe
    @issue.destroy

    respond_to do |format|
      set_issues_grid
      format.html { redirect_to issues_url, notice: t('activerecord.success.messages.destroyed', model: Issue.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_issue
    @issue = Issue.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def issue_params
    params.require(:issue).permit(
      :project_id,
      :name,
      :body,
      :gitlab_id,
      :is_existing_on_gitlab,
      :milestone_id,
      :labels,
      )
  end

  def set_issues_grid(conditions = [])
    @issues_grid = IssueGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
