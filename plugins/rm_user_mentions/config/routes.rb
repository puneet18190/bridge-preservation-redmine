# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
RedmineApp::Application.routes.draw do
  get 'rum/user_autocomplete', to: 'rum#user_autocomplete'
end