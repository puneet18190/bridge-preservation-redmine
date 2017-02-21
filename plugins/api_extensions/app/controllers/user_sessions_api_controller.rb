class UserSessionsApiController < ApplicationController


  unloadable

  # menu_item :overview
  # menu_item :settings, :only => :settings

  # before_filter :find_project, :except => [ :index, :list, :new, :create, :copy ]
  #before_filter ->(controller='qc_logs', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :new, :create, :copy, :archive, :unarchive, :destroy]
  #before_filter :authorize_global, :only => [:new, :create]
  #before_filter :require_admin, :only => [ :copy, :archive, :unarchive, :destroy ]
  #accept_rss_auth :index
  accept_api_auth :destroy
  before_filter :ensure_api_key 
  #require_sudo_mode :destroy

  # after_filter :only => [:create, :edit, :update, :archive, :unarchive, :destroy] do |controller|
  #   if controller.request.post?
  #     controller.send :expire_action, :controller => 'welcome', :action => 'robots'
  #   end
  # end

 # helper :custom_fields
  #helper :issues
  #helper :queries
  #helper :repositories
  #helper :member


  def destroy
    
    Token.where(user_id: User.current.id, action: 'session').destroy_all
    
    render :nothing => true, :status => 200
  end


  private 

  def ensure_api_key
   if User.current.is_a?(AnonymousUser)
    render json: 'Unprocessable Entity', status: 403
   end
  end

end