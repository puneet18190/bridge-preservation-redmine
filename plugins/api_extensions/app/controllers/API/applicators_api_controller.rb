class Api::ApplicatorsApiController < API::ApplicationController
  
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => [:list,  :new, :create, :copy, :archive, :unarchive, :destroy]

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
      .new(@applicators, serializer: ActiveModel::Serializer::ProjectMemberSerializer, user: User.current, project: project_scope) }
  end

  def destroy

    @applicator = Member.find(params[:id]) 
    user = User.find(@applicator.user_id)
    # memberships = Project.find(@applicator.project_id).memberships.pluck(:user_id)
    # user_groups = user.groups.where(id: memberships)
    # #remove user from the applicator group before destroying membership
    # user_groups.each do |ug| 
    #   ug.users.delete(user)
    #   if ug.users.empty?
    #     Member.find_by(user_id: ug.id).destroy rescue nil 
    #   end
    # end
    


    @applicator.destroy

    
    if @applicator.destroyed?
      render json: @applicator
    else 
      render json: {errors: 'Could not remove applicator'}, status: 422
    end
    
  end 

  private 




end