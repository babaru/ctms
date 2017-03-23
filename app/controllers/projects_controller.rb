class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :watch, :time_tracking, :sync_time_sheets_from_gitlab]
  before_action :set_redirect_url_to_session, only: [:new, :edit]
  before_action :get_redirect_url_from_session, only: [:create, :update]
  before_action :get_redirect_url_from_params, only: [:sync_from_gitlab, :sync_time_sheets_from_gitlab, :time_tracking, :watch, :destroy]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  SHOW_TABS = [:issues, :scenarios, :labels].freeze
  LIST_TABS = [:watched, :all].freeze

  PARAMETER_KEYS = {
    show: [
      :id,
      :issue_id,
      :scenario_id,
      :label_id,
      :no_label,
      :tab,
      :page
    ]
  }

  # GET /projects
  # GET /projects.json
  def index
    @list_tabs = LIST_TABS
    @current_tab = params[:tab]
    @current_tab ||= LIST_TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :all
      @query_params = {}
      build_query_params(params)
      build_query_project_params

      @conditions = []
      @conditions << Project.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

      if @conditions.length > 0
        conditions = @conditions[0]
        @conditions.each_with_index do |item, index|
          conditions = conditions.or(item) if index > 0
        end
        @conditions = conditions
      end

      respond_to do |format|
        format.html { set_projects_grid(@conditions) }
        format.json { render json: Project.where(@conditions) }
      end
    when :watched
      @projects_grid = ProjectGrid.new do |scope|
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

  def build_query_project_params
    @query_project_params = Project.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_project_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_project_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:project])
      redirect_to projects_path(@query_params)
    end
  end

  def sync_from_gitlab
    if request.post?
      Project.sync_from_gitlab(GitLabAPI.instance)

      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Project.model_name.human) }
        format.js
      end
    end
  end

  def sync_time_sheets_from_gitlab
    if request.post?
      TimeSheet.sync_from_gitlab_by_project(@project)

      respond_to do |format|
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: TimeSheet.model_name.human) }
        format.js
      end
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @tabs = SHOW_TABS
    @current_tab = params[:tab]
    @current_tab ||= SHOW_TABS.first.to_s
    @current_tab = @current_tab.to_sym

    @current_label = Label.find params[:label_id] if params[:label_id]
    @no_label = params[:no_label]

    @issue = Issue.find params[:issue_id] if params[:issue_id]
    @scenario = Scenario.find params[:scenario_id] if params[:scenario_id]

    case @current_tab
    when :issues
      @issue = Issue.find(params[:issue_id]) if params[:issue_id]
      @issue ||= @project.issues.first
      @issues_grid = IssueGrid.new do |scope|
        if @current_label
          scope.requirements.label(@current_label).where(project: @project).page(params[:page]).per(20)
        elsif @no_label
          scope.requirements.no_label.where(project: @project).page(params[:page]).per(20)
        else
          scope.requirements.where(project: @project).page(params[:page]).per(20)
        end
      end
      @issues_grid.column_names = ["gitlab_id", "title issue-info", "assignee", "milestone", "labels", "author", "scenarios"]
    when :scenarios
      @scenarios_grid = ScenarioGrid.new do |scope|
        if @current_label
          scope.page(params[:page]).joins(:labels).where(project: @project, labels: { id: @current_label.id }).per(20)
        elsif @no_label
          scenario_with_labels_ids = Scenario.joins(:labels).where(project: @project, labels: { id: Label.used_by_scenarios(@project).select(:id).distinct }).select(:id).distinct
          scope.page(params[:page]).where(project: @project, issue_id: @issue).where.not(id: scenario_with_labels_ids).per(20)
        else
          scope.page(params[:page]).where(project: @project, issue_id: @issue).per(20)
        end
      end
      @scenarios_grid.column_names = [:scenario_title, :labels, "crud_buttons project-actions"]
    when :labels
      @labels_grid = LabelGrid.new do |scope|
        scope.page(params[:page]).where(project_id: @project.id).per(20)
      end
    end
  end

  def time_tracking
    if request.post?
      respond_to do |format|
        @project.update(under_time_tracking: !@project.time_tracking?)
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Project.model_name.human) }
      end
    end
  end

  def watch
    if request.post?
      respond_to do |format|
        @project.watch(current_user)
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Project.model_name.human) }
      end
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        set_projects_grid
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.created', model: Project.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        set_projects_grid
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Project.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    respond_to do |format|
      set_projects_grid
      format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.destroyed', model: Project.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(
      :name,
      )
  end

  def set_projects_grid(conditions = [])
    @projects_grid = ProjectGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
