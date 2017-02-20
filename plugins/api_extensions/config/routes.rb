# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'projects_api/projects', to: 'projects_api#index'
get '/qc_logs_api/qc_logs', to: 'qc_logs_api#index'
post 'qc_logs_api/qc_logs', to: 'qc_logs_api#create'
