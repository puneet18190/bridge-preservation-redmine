class Api::UsersController < UsersController
  


  def show
    unless @user.visible?
      render_404
      return
    end

    # show projects based on current user visibility
    @memberships = @user.memberships.where(Project.visible_condition(User.current)).to_a

    render json: @user, serializer: ActiveModel::Serializer::UserSerializer
  end
 end
