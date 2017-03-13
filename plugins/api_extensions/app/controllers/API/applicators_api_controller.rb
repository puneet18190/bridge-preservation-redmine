class Api::ApplicatorsApiController < API::ApplicationController
  
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

    project_scope = Project.visible.find(params[:project_id]) rescue nil

    members = Member.joins(:roles).where('roles.name = ?', 'Applicator').where(project_id: project_scope.id)

    scope = User.where(id: members.pluck(:user_id))
    
    
    @applicators = paginate scope, per_page: params[:per_page], page: params[:page]
    render json: {applicators: ActiveModel::Serializer::CollectionSerializer
      .new(@applicators, serializer: ActiveModel::Serializer::ProjectMemberSerializer,
        user: User.current) }
 end

  private 




end