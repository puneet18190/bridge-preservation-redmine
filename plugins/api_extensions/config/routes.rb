# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'projects_api/projects', to: 'api/projects_api#index'
get 'projects_api/projects/:id', to: 'api/projects_api#show'
get 'qc_logs_api/qc_logs', to: 'api/qc_logs_api#index'
post 'qc_logs_api/qc_logs', to: 'api/qc_logs_api#create'
get 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#show'
delete 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#destroy'
patch 'qc_logs_api/qc_logs/:id', to: 'api/qc_logs_api#update'

delete '/user_sessions', to:  'api/user_sessions_api#destroy'
get '/user_sessions/logged_in', to: 'api/user_sessions_api#logged_in'


get 'projects_api/projects/:project_id/documents', to: 'api/documents_api#index' 
get '/document_categories', to: 'api/documents_api#document_categories' 

get 'projects_api/projects/:project_id/notes', to: 'api/notes_api#index'
get 'projects_api/projects/:project_id/applicators', to: 'api/applicators_api#index'

delete 'applicators/:id', to: 'api/applicators_api#destroy'


post 'projects_api/projects/:project_id/documents', to: 'api/documents_api#create'
put 'projects_api/projects/:project_id/documents/:id', to: 'api/documents_api#update'

get 'projects_api/projects/:project_id/documents/:id', to: 'api/documents_api#show'


get 'api_users/:id', to: 'api/users#show'
get 'api_users', to: 'api/users#index'

get 'projects_api/list_custom_field_options', to: 'api/projects_api#list_custom_field_options'