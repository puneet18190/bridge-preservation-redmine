class Api::DocumentsApiController < API::ApplicationController
  
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :new, :create, :copy, :archive, :unarchive, :destroy]

  #before_filter :authorize

  accept_rss_auth :index
  accept_api_auth :index
  require_sudo_mode :destroy


  helper :custom_fields
  helper :issues
  helper :queries
  helper :repositories
  helper :members 


  # Lists visible projects
 def index
    scope = Document.where(project_id: Project.visible.find(params[:project_id])).includes(:attachments) rescue []

    
    
    @documents = paginate scope, per_page: params[:per_page], page: params[:page]
    render json: {documents: ActiveModel::Serializer::CollectionSerializer
      .new(@documents, serializer: ActiveModel::Serializer::DocumentSerializer,
        user: User.current) }
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




end