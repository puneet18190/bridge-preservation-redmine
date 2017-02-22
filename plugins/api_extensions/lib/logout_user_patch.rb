# Patches Redmine's Users dynamically.
module LogoutUserPatch
  def self.included(base) # :nodoc:
    base.class_eval do
      unloadable

      #remove all session tokens to enforce logged in and logged out between redmine and client application
       def logout_user
        if User.current.logged?
          cookies.delete(autologin_cookie_name)
          Token.delete_all(["user_id = ? AND action = ?", User.current.id, 'autologin'])
          Token.delete_all(["user_id = ? AND action = ?", User.current.id, 'session'])
          self.logged_user = nil
       end
     end
    end
  end
end
