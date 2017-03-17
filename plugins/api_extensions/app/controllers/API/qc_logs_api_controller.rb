class Api::QcLogsApiController < API::ApplicationController


  unloadable

  menu_item :overview
  menu_item :settings, :only => :settings

#  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy ]
  before_filter ->(controller='qc_logs', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :index, :new, :create, :copy, :archive, :unarchive, :destroy]
  before_filter ->(controller='qc_logs', action=params[:action]) {authorize_global(controller, action, true) }, :only => [:new, :create]
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
    byebug
    scope = QcLog.visible

    scope = search_filter(scope)

    @qc_logs = paginate scope, per_page: params[:per_page], page: params[:page]
    #included_data = params[:include].split(',') rescue []
    #include_activities = included_data.include?('activities')

    render json:  @qc_logs

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


    if params["qc_log"].present? && params["qc_log"]["sample_date"].present?
      params["qc_log"]["sample_date"] = Date.strptime(params["qc_log"]["sample_date"], "%m/%d/%Y")
    end

    if params["qc_log"].present? && params["qc_log"]["project_id"].present?
      params["qc_log"]["project"] = Project.find(params["qc_log"]["project_id"].to_i)
    end

    qc_log = QcLog.new(qc_log_params)

    if qc_log.save
    
      render json:  { qc_log: qc_log }
    else
      render json:  { qc_log: render_validation_errors(qc_log) }, status: :unprocessable_entity
    end
  end

  def show
    qc_log = QcLog.find(params[:id])
    render json: { qc_log: qc_log }
  end

  def update
    if params["qc_log"].present? && params["qc_log"]["date"].present?
      params["qc_log"]["date"] = Date.strptime(params["qc_log"]["date"], "%m/%d/%Y")
    end

    if params["qc_log"].present? && params["qc_log"]["sample_date"].present?
      params["qc_log"]["sample_date"] = Date.strptime(params["qc_log"]["sample_date"], "%m/%d/%Y")
    end

    if params["qc_log"].present? && params["qc_log"]["project_id"].present?
      params["qc_log"]["project"] = Project.find(params["qc_log"]["project_id"].to_i)
    end


    qc_log = QcLog.find(params[:id])

    if qc_log.update_attributes(qc_log_params)
   
      render json:  { qc_log: qc_log }
    else
      render json:  { qc_log: render_validation_errors(qc_log) }, status: :unprocessable_entity
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
  end

  private

  def search_filter(scope)
    filter_params = params[:filters] || {}
    filter_params = filter_params.reject{|k, v|  v.blank? }
    scope = scope.has_project_with_id(filter_params[:project_id]) if filter_params[:project_id]
    scope = scope.has_user_with_id(filter_params[:user_id]) if filter_params[:user_id]
    scope = scope.with_date_between(filter_params[:from_date], filter_params[:to_date]) if filter_params[:from_date] || filter_params[:to_date]
    scope = scope.text_search(filter_params) if filter_params.is_a?(Hash)
    return scope

  end

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
        :inspector,
        :project,
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
        :status,
        :spray_membrane_application => [:product, :lot_a_number, :lot_a_temperature, :lot_b_number, :lot_b_temperature, :no_gallons_used, :application_equipment, :spray_gun, :spray_module, :set_iso, :set_resin, :set_hose, :temperature_iso, :temperature_resin, :temperature_hose, :pressure_set, :pressure_spray],
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
