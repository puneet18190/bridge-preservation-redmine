RedmineApp::Application.routes.draw do
  get 'acl/upload_icons', controller: :acl_style_css, action: :upload_icons
  post 'acl/upload_icons', controller: :acl_style_css, action: :upload_icons

  get 'custom_fields/:id/ajax_values', controller: :custom_fields, action: :ajax_values
end

