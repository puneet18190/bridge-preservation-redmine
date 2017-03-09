class ProjectsApiController < ApplicationController
  

  unloadable
  
  menu_item :overview
  menu_item :settings, :only => :settings

  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy ]
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :new, :create, :copy, :archive, :unarchive, :destroy]
  before_filter :authorize_global, :only => [:new, :create]
  before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  #before_filter :set_current_user
  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy
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
    scope = all_search_filters(scope)

    @offset, @limit = api_offset_and_limit
    @project_count = scope.count
    @projects = scope.offset(@offset).limit(@limit).to_a
    included_data = params[:include].split(',') rescue []

    include_activities = included_data.include?('activities')
  

    render json: {projects: ActiveModel::Serializer::CollectionSerializer
      .new(@projects, serializer: ActiveModel::Serializer::ProjectSerializer, include_activities: include_activities, 
        user: User.current,  from: (Date.today - 5.days).to_datetime, to: Date.tomorrow.to_datetime, limit: 5) }
 end


  private 

  def all_search_filters(scope)
    scope = search_filter(scope)
    scope = custom_field_search_filter(scope)
  end

  def search_filter(scope)
    filter_params = params[:filters]
    scope = scope.has_project_with_id(params[:project_id]) if params[:project_id]
    scope = scope.text_search(filter_params) if filter_params.is_a?(Hash)
    return scope

  end

  def custom_field_search_filter(scope)
    project_ids = []
    scope_ids = scope.ids
    filter_params = params[:filters] || {}
    filter_params = filter_params.reject{|k, v| v.blank? }
    custom_fields_filters = filter_params.keys.map{|m| m.downcase} rescue []
    custom_fields =  ProjectCustomField.where('lower(name) in (?)', custom_fields_filters)
    custom_fields.each do |c| 

      filter_value = filter_params[c.name.downcase.to_sym] 

      unless  c.name == "Owner" 
        new_ids  = CustomValue.where(customized_type: 'Project', customized_id: scope_ids, custom_field_id: c.id).
                      where('value ILIKE ?', "%#{filter_value}%").pluck(:customized_id)
      else 
        filter_value = Contact.where('first_name ILIKE ?', "%#{filter_value}%").ids.map(&:to_s)
        new_ids = CustomValue.where(customized_type: 'Project', customized_id: scope_ids, custom_field_id: c.id).
                      where('value IN (?)', filter_value).pluck(:customized_id)
      end
      scope_ids = scope_ids.select{|m| new_ids.include?(m)}
    end
    return scope.where(id: scope_ids)
  end


end
