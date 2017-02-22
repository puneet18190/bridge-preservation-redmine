class QcLogsApiController < ApplicationController


  unloadable

  menu_item :overview
  menu_item :settings, :only => :settings

#  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy ]
  before_filter ->(controller='qc_logs', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :new, :create, :copy, :archive, :unarchive, :destroy]
  before_filter :authorize_global, :only => [:new, :create]
  before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy
  require_sudo_mode :destroy

  after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
    if controller.request.post?
      controller.send :expire_action, :controller => 'welcome', :action => 'robots'
    end
  end

  helper :custom_fields
  # helper :issues
  helper :queries
  helper :repositories
  helper :members


  # Lists visible projects
 def index
    scope = QcLog.visible

    @offset, @limit = api_offset_and_limit
    @qc_log_count = scope.count
    @qc_logs = scope.offset(@offset).limit(@limit).to_a
    #included_data = params[:include].split(',') rescue []
    #include_activities = included_data.include?('activities')

    render json:  @qc_logs
    #render json: {projects: ActiveModel::Serializer::CollectionSerializer
    #  .new(@projects, serializer: ActiveModel::Serializer::ProjectSerializer, include_activities: include_activities, user: User.current, from: Date.today - 5.days, to: Date.today, limit: 5) }


  end

  # def new
  #   @issue_custom_fields = IssueCustomField.sorted.to_a
  #   @trackers = Tracker.sorted.to_a
  #   @project = Project.new
  #   @project.safe_attributes = params[:project]
  # end

  def create
    # Parse the text date so it actually saves as a date
    if params["qc_log"].present? && params["qc_log"]["date"].present?
      params["qc_log"]["date"] = Date.strptime(params["qc_log"]["date"], "%m/%d/%Y")
    end

    @qc_log = QcLog.new(qc_log_params)

    if @qc_log.save
      unless User.current.admin?
        @qc_log.add_default_member(User.current)
      end
      render json:  { qc_log: @qc_log }
    else
      render json:  { qc_log: render_validation_errors(@qc_log) }, status: :unprocessable_entity
    end
  end

  def show
    byebug
    @qc_log = QcLog.find(params[:id])
    render json: { qc_log: @qc_log }
  end

  def update
    @qc_log = QcLog.find(params[:id])
    if @qc_log.update_attributes(qc_log_params)
      unless User.current.admin?
        @qc_log.add_default_member(User.current)
      end
      render json:  { qc_log: @qc_log }
    else
      render json:  { qc_log: render_validation_errors(@qc_log) }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      qc_log = QcLog.find(params[:id])
      qc_log.destroy

      render json: {}, status: :no_content
    rescue ActiveRecord::RecordNotFound
      render :json => {}, :status => :not_found
  end

  # def copy
  #   @issue_custom_fields = IssueCustomField.sorted.to_a
  #   @trackers = Tracker.sorted.to_a
  #   @source_project = Project.find(params[:id])
  #   if request.get?
  #     @project = Project.copy_from(@source_project)
  #     @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
  #   else
  #     Mailer.with_deliveries(params[:notifications] == '1') do
  #       @project = Project.new
  #       @project.safe_attributes = params[:project]
  #       if @project.copy(@source_project, :only => params[:only])
  #         flash[:notice] = l(:notice_successful_create)
  #         redirect_to settings_project_path(@project)
  #       elsif !@project.new_record?
  #         # Project was created
  #         # But some objects were not copied due to validation failures
  #         # (eg. issues from disabled trackers)
  #         # TODO: inform about that
  #         redirect_to settings_project_path(@project)
  #       end
  #     end
  #   end
  # rescue ActiveRecord::RecordNotFound
  #   # source_project not found
  #   render_404
  # end

  # # Show @project
  # def show
  #   # try to redirect to the requested menu item
  #   if params[:jump] && redirect_to_project_menu_item(@project, params[:jump])
  #     return
  #   end

  #   @users_by_role = @project.users_by_role
  #   @subprojects = @project.children.visible.to_a
  #   @news = @project.news.limit(5).includes(:author, :project).reorder("#{News.table_name}.created_on DESC").to_a
  #   @trackers = @project.rolled_up_trackers.visible

  #   cond = @project.project_condition(Setting.display_subprojects_issues?)

  #   @open_issues_by_tracker = Issue.visible.open.where(cond).group(:tracker).count
  #   @total_issues_by_tracker = Issue.visible.where(cond).group(:tracker).count

  #   if User.current.allowed_to_view_all_time_entries?(@project)
  #     @total_hours = TimeEntry.visible.where(cond).sum(:hours).to_f
  #   end

  #   @key = User.current.rss_key

  #   respond_to do |format|
  #     format.html
  #     format.api
  #   end
  # end

  # def settings
  #   @issue_custom_fields = IssueCustomField.sorted.to_a
  #   @issue_category ||= IssueCategory.new
  #   @member ||= @project.members.new
  #   @trackers = Tracker.sorted.to_a
  #   @wiki ||= @project.wiki || Wiki.new(:project => @project)
  # end

  # def edit
  # end

  # def update
  #   @project.safe_attributes = params[:project]
  #   if @project.save
  #     respond_to do |format|
  #       format.html {
  #         flash[:notice] = l(:notice_successful_update)
  #         redirect_to settings_project_path(@project)
  #       }
  #       format.api  { render_api_ok }
  #     end
  #   else
  #     respond_to do |format|
  #       format.html {
  #         settings
  #         render :action => 'settings'
  #       }
  #       format.api  { render_validation_errors(@project) }
  #     end
  #   end
  # end

  # def modules
  #   @project.enabled_module_names = params[:enabled_module_names]
  #   flash[:notice] = l(:notice_successful_update)
  #   redirect_to settings_project_path(@project, :tab => 'modules')
  # end

  # def archive
  #   unless @project.archive
  #     flash[:error] = l(:error_can_not_archive_project)
  #   end
  #   redirect_to admin_projects_path(:status => params[:status])
  # end

  # def unarchive
  #   unless @project.active?
  #     @project.unarchive
  #   end
  #   redirect_to admin_projects_path(:status => params[:status])
  # end

  # def close
  #   @project.close
  #   redirect_to project_path(@project)
  # end

  # def reopen
  #   @project.reopen
  #   redirect_to project_path(@project)
  # end

  private

  def qc_log_params
      params.require(:qc_log).permit(
        :date,
        :environmental_description,
        :substrate_square_footage,
        :substrate_equipment,
        :substrate_surface_preparation_standard,
        :substrate_profile,
        :substrate,
        :substrate_media,
        :substrate_general_comments,
        :user_id,
        :user_id,
        :project_id,
        :approved_applicator,
        :square_footage,
        :location_name,
        :location_latitude,
        :location_longitude,
        :bridge_id,
        :bridge_name,
        :primer_product,
        :primer_lot_a_number,
        :primer_lot_a_temperature,
        :primer_lot_b_number,
        :primer_lot_b_temperature,
        :primer_gallons_used,
        :primer_application_equipment,
        :primer_spray_gun,
        :primer_spray_module,
        :primer_comments,
        :spray_membrane_application,
        :application_thickness_instrument,
        :application_thickness_method,
        :adhesion_testing_instrument,
        :adhesion_testing_method,
        :general_application_comments,
        :sample_retained,
        :sample_quantity,
        :sample_date,
        :sample_sent_by,
        :signature,
        :environmental_conditions => [:time, :temperature, :humidity, :wind_velocity, :substrate_temperature, :substrate_moisture, :dew_point],
        :adhesion_testing_value_and_mode => [:value, :mode_of_failure],
        :application_value_and_location  => [:value, :location]
        )
    end

  # # Delete @project
  # def destroy
  #   @project_to_destroy = @project
  #   if api_request? || params[:confirm]
  #     @project_to_destroy.destroy
  #     respond_to do |format|
  #       format.html { redirect_to admin_projects_path }
  #       format.api  { render_api_ok }
  #     end
  #   end
  #   # hide project in layout
  #   @project = nil
  # end
end
