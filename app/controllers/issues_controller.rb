class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: [:show, :edit, :update, :destroy, :edit_defect_corresponding, :update_defect_corresponding, :sync_time_sheets_from_gitlab]
  before_action :set_redirect_url_to_session, only: [:new, :edit, :new_defect]
  before_action :get_redirect_url_from_session, only: [:create, :update, :create_defect]
  before_action :get_redirect_url_from_params, only: [:sync_time_sheets_from_gitlab, :destroy]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  TABS = [:scenarios].freeze

  PARAMETER_KEYS = {
    show: [
      :id,
      :project_id,
      :scenario_id,
      :label_id,
      :no_label,
    ]
  }

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
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: TimeSheet.model_name.human) }
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
  end

  def new_defect
    @defect = Defect.new(scenario_id: params[:scenario_id], round_id: params[:round_id], corresponding_issue_id: params[:corresponding_issue_id], project_id: params[:project_id])
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    respond_to do |format|
      if @issue.save
        set_issues_grid
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.created', model: Issue.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  def create_defect
    if request.post?
      respond_to do |format|
        @defect = Defect.new(defect_params)
        if @defect.post_defect_to_gitlab(current_user.access_token)
          format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.created', model: Defect.model_name.human) }
          format.js
        else
          format.html { render :new_defect }
          format.js { render :new_defect }
        end
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)
        set_issues_grid
        format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.updated', model: Issue.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  def edit_defect_corresponding
    @issue.labels_text = @issue.labels.inject([]) {|list, label| list << label.name }.join(',')
  end

  def update_defect_corresponding
    respond_to do |format|
      if request.post?
        if @issue.update(defect_params)
          format.js
        else
          format.js { render :edit_defect_corresponding }
        end
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
    @issue.destroy

    respond_to do |format|
      set_issues_grid
      format.html { redirect_to redirect_url, notice: t('activerecord.success.messages.destroyed', model: Issue.model_name.human) }
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
      :title,
      :description,
      :scenario_id,
      :round_id,
      :project_id,
      :name,
      :body,
      :gitlab_id,
      :is_existing_on_gitlab,
      :milestone_id,
      :labels,
      :labels_text
      )
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :description,
      :scenario_id,
      :round_id,
      :project_id,
      :corresponding_issue_id,
      :gitlab_id,
      :is_existing_on_gitlab,
      :milestone_id,
      :labels,
      :labels_text
      )
  end

  def set_issues_grid(conditions = [])
    @issues_grid = IssueGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
