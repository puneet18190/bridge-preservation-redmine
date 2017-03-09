# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'projects_api/projects', to: 'api/projects_api#index'
get 'qc_logs_api/qc_logs', to: 'api/qc_logs_api#index'
post 'qc_logs_api/qc_logs', to: 'api/qc_logs_api#create'
get 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#show'
delete 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#destroy'
patch 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#update'

delete '/user_sessions', to:  'api/user_sessions_api#destroy'
get '/user_sessions/logged_in', to: 'api/user_sessions_api#logged_in'
