require 'oauth/controllers/provider_controller'
class OauthController < ApplicationController
  unloadable
  skip_filter :check_if_login_required
  include OAuth::Controllers::ProviderController

  before_filter :login_or_oauth_required, :only => [:user_info]

  def logged_in?
    User.current.logged?
  end

  def login_required
    raise Unauthorized unless User.current.logged?
  end

  def user_info
    user_hash = { :user => {} }
    user = User.find(session[:user_id])
    if user
      hash = user.attributes
      hash.delete(:hashed_password)
      hash.delete(:salt)
      hash.merge!(:mail => user.mail)
      hash.merge!(:api_key => user.api_key) 
      user_hash = { :user => hash }
    end
    respond_to do |format|
      format.json { render :json => user_hash }
    end
  end

  def current_user
    User.find(session[:user_id])
  end

  def current_user=(user)
    start_user_session(user)
  end

  def authorize_with_allow
    params[:authorize] = '1' if params[:allow]
    authorize_without_allow
  end
  alias_method_chain :authorize, :allow

   def authorize
        if params[:oauth_token] || true
          @token = ::RequestToken.find_by_token! params[:oauth_token] rescue nil
          oauth1_authorize
        else
          if request.post?
            @authorizer = OAuth::Provider::Authorizer.new current_user, user_authorizes_token?, params
            redirect_to @authorizer.redirect_uri
          else
            @client_application = ClientApplication.find_by_key! params[:client_id]
            render :action => "oauth2_authorize"
          end
        end
  end
  
  protected
  #for now we overwrite the authorize method to skip the authorize step for users
  def oauth1_authorize


   unless @token  
          render :action=>"authorize_failure"
          return
   end


    unless @token.invalidated? 
       if request.post? || true 
            if user_authorizes_token? || true 
              @token.authorize!(current_user)
              callback_url  = @token.oob? ? @token.client_application.callback_url : @token.callback_url
              @redirect_url = URI.parse(callback_url) unless callback_url.blank?

              unless @redirect_url.to_s.blank?
                @redirect_url.query = @redirect_url.query.blank? ?
                                      "oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}" :
                                      @redirect_url.query + "&oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
                redirect_to @redirect_url.to_s
              else
                render :action => "authorize_success"
              end
            else
              @token.invalidate!
              render :action => "authorize_failure"
            end
          end
        else
          render :action => "authorize_failure"
        end
  end



end
