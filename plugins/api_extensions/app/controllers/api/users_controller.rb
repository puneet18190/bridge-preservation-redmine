class Api::UsersController < UsersController
 

 def index
    sort_init 'login', 'asc'
    sort_update %w(login firstname lastname admin created_on last_login_on)

    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    @status = params[:status] || 1

    scope = User.logged.status(@status).preload(:email_address)
    scope = scope.like(params[:name]) if params[:name].present?
    scope = scope.in_group(params[:group_id]) if params[:group_id].present?
    unless User.current.admin?
     scope = scope_by_role(scope)
    end

    @user_count = scope.count
    @user_pages = Paginator.new @user_count, @limit, params['page']
    @offset ||= @user_pages.offset
    @users =  scope.order(sort_clause).limit(@limit).offset(@offset).to_a

    respond_to do |format|
      format.html {
        @groups = Group.givable.sort
        render :layout => !request.xhr?
      }
      format.api
    end
 end
  
  def show
    unless @user.visible?
      render_404
      return
    end

    # show projects based on current user visibility
    @memberships = @user.memberships.where(Project.visible_condition(User.current)).to_a

    render json: @user, serializer: ActiveModel::Serializer::UserSerializer
  end
 
 private 

 def require_admin
 	return unless require_login

 	true
 end

 def scope_by_role(scope)


    current_user_groups = User.current.groups.select{|g| !g.memberships.empty?}
    roles = User.current.projects_by_role.keys.map(&:name)
    not_user_ids = []
    
    if roles.include?('Applicator')
      users  = User.where(id: scope.collect{|c| c.id}.flatten - [User.current.id])


      user_id_and_roles = users.collect{|u| {user: u,  role_names: u.projects_by_role.keys.map(&:name) }}.flatten
  

      not_users = user_id_and_roles.flatten.select{|s| s[:role_names].include?('Applicator')}.map{|m| m[:user]}
      	


      not_users.each do |u|

        user_groups = u.groups.select{|g| !g.memberships.empty? }
        
        
        unless !(current_user_groups.map(&:id) & user_groups.map(&:id) ).empty?
          not_user_ids << u.id 
        end
      end
    end


      scope = scope.where.not(id: not_user_ids) if !not_user_ids.empty?
      return scope
 end
end
