class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :time_tracking]

  QUERY_KEYS = [:name].freeze
  ARRAY_SP = ","
  ARRAY_HEADER = "a_"

  SHOW_TABS = [:tab1, :tab2].freeze
  LIST_TABS = [:all].freeze

  # GET /users
  # GET /users.json
  def index
    @list_tabs = LIST_TABS
    @current_tab = params[:tab]
    @current_tab ||= LIST_TABS.first.to_s
    @current_tab = @current_tab.to_sym

    case @current_tab
    when :all
      @query_params = {}
      build_query_params(params)
      build_query_user_params

      @conditions = []
      @conditions << User.arel_table[:name].matches("%#{@query_params[:name]}%") if @query_params[:name]

      if @conditions.length > 0
        conditions = @conditions[0]
        @conditions.each_with_index do |item, index|
          conditions = conditions.or(item) if index > 0
        end
        @conditions = conditions
      end

      respond_to do |format|
        format.html { set_users_grid(@conditions) }
        format.json { render json: User.where(@conditions) }
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

  def build_query_user_params
    @query_user_params = User.new
    QUERY_KEYS.each do |key|
      if @query_params[key] && @query_params[key].start_with?(ARRAY_HEADER)
        @query_user_params.send("#{key}=", @query_params[key].gsub(ARRAY_HEADER, "").split(ARRAY_SP))
      else
        @query_user_params.send("#{key}=", @query_params[key])
      end
    end
  end

  def search
    if request.post?
      @query_params = {}
      build_query_params(params[:user])
      redirect_to users_path(@query_params)
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @show_tabs = SHOW_TABS
    @current_tab = params[:tab]
    @current_tab ||= SHOW_TABS.first.to_s
    @current_tab = @current_tab.to_sym
  end

  def time_tracking
    if request.post?
      respond_to do |format|
        @user.update(under_time_tracking: !@user.time_tracking?)
        format.html { redirect_to params[:redirect_url], notice: t('activerecord.success.messages.updated', model: User.model_name.human) }
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        set_users_grid
        format.html { redirect_to @user, notice: t('activerecord.success.messages.created', model: User.model_name.human) }
        format.js
      else
        format.html { render :new }
        format.js { render :new }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        set_users_grid
        format.html { redirect_to @user, notice: t('activerecord.success.messages.updated', model: User.model_name.human) }
        format.js
      else
        format.html { render :edit }
        format.js { render :edit }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      set_users_grid
      format.html { redirect_to users_url, notice: t('activerecord.success.messages.destroyed', model: User.model_name.human) }
      format.js
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :email,
      :encrypted_password,
      :reset_password_token,
      :reset_password_sent_at,
      :remember_created_at,
      :sign_in_count,
      :current_sign_in_at,
      :last_sign_in_at,
      :current_sign_in_ip,
      :last_sign_in_ip,
      :provider,
      :uid,
      :name,
      :image,
      :access_token,
      :under_time_tracking,
      :username,
      )
  end

  def set_users_grid(conditions = [])
    @users_grid = UserGrid.new do |scope|
      scope.page(params[:page]).where(conditions).per(20)
    end
  end
end
