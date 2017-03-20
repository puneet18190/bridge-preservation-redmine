class Api::DocumentsApiController < API::ApplicationController
  
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => 
  [:list, :index, :new, :create, :copy, :archive, :unarchive, :destroy,
    :document_categories]
  before_action :set_scope, only: [:index, :create, :show, :update]
  #before_filter :authorize

  accept_rss_auth :index
  accept_api_auth :index, :create, :show, :document_categories, :update
  require_sudo_mode :destroy


  helper :custom_fields
  helper :issues
  helper :queries
  helper :repositories
  helper :members 

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  # Lists visible projects
 def index
    scope = @scope.includes(attachments: :author) rescue []


    @documents = paginate scope, per_page: params[:per_page], page: params[:page]
    render json: {documents: ActiveModel::Serializer::CollectionSerializer.new(@documents, 
        serializer: ActiveModel::Serializer::DocumentSerializer,
        user: User.current), 
       categories: DocumentCategory.all}
end

 def show
    #scope = Document.where(project_id: @project) rescue []
      
    scope = @scope.find(params[:id])


    render json: scope, serializer: ActiveModel::Serializer::DocumentSerializer

 end

 def create

    @document = @project.documents.build
    @document.safe_attributes = params[:document]

    file_info = params[:attachments]
    
    unless !file_info
      attachment = Attachment.new(:file => request.raw_post)
      attachment.author = User.current
      attachment.filename = file_info.original_filename.presence || Redmine::Utils.random_hex(16)
      attachment.content_type = file_info.content_type.presence
      attachment.container_type = 'Document'
      saved = attachment.save
    end
    
    if @document.save && saved
      attachment.update(container_id: @document.id )
      render json: @document, serializer: ActiveModel::Serializer::DocumentSerializer
    else
      attachment_errors = attachment.errors.full_messages rescue []
      no_file_error = ["A file must be uploaded"] if !file_info
      render json: {errors: @document.errors.full_messages + attachment_errors + no_file_error  }, status: 422
    end
  end

  def update
    @document = @project.documents.find(params[:id])
    @document.safe_attributes = params[:document]

    file_info = params[:attachments]
    
    unless !file_info
      @document.attachments.each do |a|
        a.destroy
      end
      attachment = Attachment.new(:file => request.raw_post)
      attachment.author = User.current
      attachment.filename = file_info.original_filename.presence || Redmine::Utils.random_hex(16)
      attachment.content_type = file_info.content_type.presence
      attachment.container_type = 'Document'
      saved = attachment.save
    end
    
    if @document.save 
      attachment.update(container_id: @document.id ) if attachment
      render json: @document, serializer: ActiveModel::Serializer::DocumentSerializer
    else
  
      render json: {errors: @document.errors.full_messages }, status: 422
    end

  end

  def document_categories

    render json: DocumentCategory.all
  end

  private 

  
  def set_scope
    @project = Project.visible.find(params[:project_id])
    @scope = Document.where(project_id: @project) 
    current_user_groups = User.current.groups.select{|g| !g.memberships.where(project:@project).empty?}
    current_project_roles = User.current.roles_for_project(@project).map(&:name)
    if current_project_roles.include?('Applicator')
      users  = User.where(id: @scope.collect{|c| c.attachments.map(&:author_id)}.flatten - [User.current.id])


      user_id_and_roles = users.collect{|u| {user: u,  role_names: u.roles_for_project(@project).map(&:name) }}.flatten
  

      not_users = user_id_and_roles.flatten.select{|s| s[:role_names].include?('Applicator')}.map{|m| m[:user]}
      not_user_ids = []


      not_users.each do |u|
        user_groups = u.groups.select{|g| !g.memberships.where(project: @project).empty? }

        unless !(current_user_groups.map(&:id) & user_groups.map(&:id) ).empty?
          not_user_ids << u.id 
        end
      end



      @scope = @scope.joins(:attachments).where.not('attachments.author_id IN (?)', not_user_ids) if !not_user_ids.empty?
    end 

  end

  def record_not_found
    render json: {errors: "Not Found"}, status: 404
  end

  def search_filter(scope)
    filter_params = params[:filters]
    scope = scope.has_project_with_id(params[:project_id]) if params[:project_id]
    scope = scope.text_search(filter_params) if filter_params.is_a?(Hash)
    return scope

  end
end