class TimeSheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_sheet, only: [:show, :edit, :update, :destroy]

  # GET /time_sheets
  # GET /time_sheets.json
  def index
    @year = params[:calendar].split('-').first.to_i if params[:calendar]
    @month = params[:calendar].split('-').last.to_i if params[:calendar]
    logger.debug @year
    @year ||= Time.current.year
    @month ||= Time.current.month
    @first_day = Time.new(@year, @month, 1)
    @last_day = Time.new(@year, @month, Time.days_in_month(@month, @year))

    respond_to do |format|
      format.html
    end
  end

  # GET /time_sheets/1
  # GET /time_sheets/1.json
  def show
    @tabs = TABS
    @current_tab = params[:tab]
    @current_tab ||= TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  def sync_from_gitlab
    if request.post?
      respond_to do |format|
        TimeSheet.sync_from_gitlab
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: TimeSheet.model_name.human) }
      end
    end
  end

  # GET /time_sheets/new
  def new
    @time_sheet = TimeSheet.new
  end

  # GET /time_sheets/1/edit
  def edit
  end

  # POST /time_sheets
  # POST /time_sheets.json
  def create
    @time_sheet = TimeSheet.new(time_sheet_params)

    respond_to do |format|
      if @time_sheet.save
        set_time_sheets_grid
        format.html { redirect_to @time_sheet, notice: t('activerecord.success.messages.created', model: TimeSheet.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /time_sheets/1
  # PATCH/PUT /time_sheets/1.json
  def update
    respond_to do |format|
      if @time_sheet.update(time_sheet_params)
        set_time_sheets_grid
        format.html { redirect_to @time_sheet, notice: t('activerecord.success.messages.updated', model: TimeSheet.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /time_sheets/1
  # DELETE /time_sheets/1.json
  def destroy
    @time_sheet.destroy

    respond_to do |format|
      set_time_sheets_grid
      format.html { redirect_to time_sheets_url, notice: t('activerecord.success.messages.destroyed', model: TimeSheet.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_sheet
    @time_sheet = TimeSheet.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def time_sheet_params
    params.require(:time_sheet).permit(
      :user_id,
      :issue_id,
      :project_id,
      :spent,
      :spent_at,
      )
  end

  def set_time_sheets_grid(conditions = [])
    @time_sheets_grid = TimeSheetGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
