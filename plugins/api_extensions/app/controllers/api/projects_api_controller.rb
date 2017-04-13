class Api::ProjectsApiController < Api::ApplicationController
  

  unloadable
  menu_item :overview
  menu_item :settings, :only => :settings

  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy, :list_custom_field_options ]
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :list_custom_field_options, :index, :new, :create, :copy, :archive, :unarchive, :destroy]
  before_filter :authorize_global, :only => [:new, :create]
  before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  #before_filter :set_current_user
  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy, :list_custom_field_options
  require_sudo_mode :destroy
 
  after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
    if controller.request.post?
      controller.send :expire_action, :controller => 'welcome', :action => 'robots'
    end
  end

  helper :custom_fields
  helper :issues
  helper :queries
  helper :repositories
  helper :members 


  # Lists visible projects
 def index

    scope = Project.visible.sorted
    scope = all_search_filters(scope).includes(:products, :custom_values)
    
    #@offset, @limit = api_offset_and_limit
    #@project_count = scope.count
   # @projects = scope.offset(@offset).limit(@limit).to_a
    included_data = params[:include].split(',') rescue []
    

    include_activities = included_data.include?('activities')
    @projects = paginate scope, per_page: params[:per_page], page: params[:page]
    render json: {projects: ActiveModel::Serializer::CollectionSerializer
      .new(@projects, serializer: ActiveModel::Serializer::ProjectSerializer, include_activities: include_activities, 
        user: User.current,  from: (Date.today - 5.days).to_datetime, to: Date.tomorrow.to_datetime, limit: 5) }
 end

 def show 
  scope = Project.visible.find(params[:id])
  included_data = params[:include].split(',') rescue []
  include_activities = included_data.include?('activities')

  render json: scope, serializer: ActiveModel::Serializer::ProjectSerializer, include_activities: include_activities, 
        user: User.current,  from: (Date.today - 5.days).to_datetime, to: Date.tomorrow.to_datetime, limit: 5
 end

 def list_custom_field_options
  field = ProjectCustomField.find_by(name: params[:field_name]) rescue nil 
  options = field.possible_values if field
  render json: options 

 end
  
  private 

  def all_search_filters(scope)
    scope = search_filter(scope)
    scope = custom_field_search_filter(scope)
  end

  def search_filter(scope)
    filter_params = params[:filters] || {}
    scope = scope.where(id: filter_params[:project_id]) if filter_params[:project_id]
    scope = scope.text_search(filter_params) if filter_params.is_a?(Hash)
    return scope

  end

  def custom_field_search_filter(scope)
    project_ids = []
    scope_ids = scope.ids
    filter_params = params[:filters] || {}
    filter_params = filter_params.reject{|k, v| v.blank? }
    custom_fields_filters = filter_params.keys.map{|m| m.downcase} rescue []
    custom_fields =  ProjectCustomField.where('lower(name) in (?)', custom_fields_filters
      .map{|v| v.gsub(/(_min|_max|_from|_to)/, '').gsub('_', ' ') })
    
    custom_fields.each do |c| 
      param_name = c.name.gsub(' ', '').underscore
      filter_value = filter_params[param_name] 
      
      case  c.name
      
        when "Owner", "General Contractor"
         filter_value = Contact.where('first_name ILIKE ?', "%#{filter_value}%").ids.map(&:to_s)
         new_ids = CustomValue.where(customized_type: 'Project', customized_id: scope_ids, custom_field_id: c.id).
                      where('value IN (?)', filter_value).pluck(:customized_id)
        when "Square Footage", "Bid Date"
           
           min = filter_params[param_name+'_min']
           max = filter_params[param_name+'_max']
           
           case c.field_format
            when 'date'
              min = (Date.strptime(min, "%m/%d/%Y") rescue nil) || Date.today
              max = Date.strptime(max, "%m/%d/%Y") rescue nil
              cast_expres = "CAST (nullif(value, '') AS DATE)"
            else
             min = min.try(:to_i) || 0
             max = max.try(:to_i) 
             cast_expres = "CAST (COALESCE(nullif(value, ''), '0') AS INTEGER)"
           end

           query_string = "#{cast_expres} >= :min"
           query_string += " AND #{cast_expres} <= :max" if max 
           query_params = {min: min}
           query_params[:max] = max if max 
           new_ids  = CustomValue.where(customized_type: 'Project', customized_id: scope_ids, custom_field_id: c.id).
                        where(query_string, query_params).pluck(:customized_id)
        else
          new_ids  = CustomValue.where(customized_type: 'Project', customized_id: scope_ids, custom_field_id: c.id).
                        where('value ILIKE ?', "%#{filter_value}%").pluck(:customized_id)
        end
        scope_ids = scope_ids.select{|m| new_ids.include?(m)}
    end
    return scope.where(id: scope_ids)
  end


end
