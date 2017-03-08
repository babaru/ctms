class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:issues, :scenarios].freeze

  # GET /projects
  # GET /projects.json
  def index
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
      Project.all.update(is_existing_on_gitlab: false)
      GitLabAPI.instance.projects.each do |project_data|
        project = Project.find_by_gitlab_id(project_data["id"]) || Project.create(name: project_data["name_with_namespace"], gitlab_id: project_data["id"])
        project.update(name: project_data["name_with_namespace"],
          gitlab_id: project_data["id"],
          is_existing_on_gitlab: true)
      end

      respond_to do |format|
        format.html { redirect_to projects_path }
        format.js
      end
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :scenarios
      @scenarios_grid = ScenarioGrid.new do |scope|
        scope.page(params[:page]).where([]).per(20)
      end
    when :issues
      @issue = Issue.find(params[:issue_id]) if params[:issue_id]
      @issue ||= @project.issues.first
      @issues_grid = IssueGrid.new do |scope|
        scope.page(params[:page]).where(project_id: @project.id).per(20)
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
        format.html { redirect_to projects_path, notice: t('activerecord.success.messages.created', model: Project.model_name.human) }
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
        format.html { redirect_to projects_path, notice: t('activerecord.success.messages.updated', model: Project.model_name.human) }
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
      format.html { redirect_to projects_url, notice: t('activerecord.success.messages.destroyed', model: Project.model_name.human) }
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
