class UserSerializer < ActiveModel::Serializer
  unloadable

  attributes *User.attribute_names.reject{|r| ['hashed_password', 'salt'].include?(r) }, :roles
  include Rails.application.routes.url_helpers


  def roles
  	project_roles = {}
  	project_memberships = object.memberships.includes(:roles)
  	project_memberships.each do |m|

  		project_roles[:project_id] = m.project_id
  		project_roles[:role_names] = m.roles.map(&:name)
  		project_roles[:permissions] = m.roles.map(&:permissions).flatten.uniq
  	end
  	return project_roles 
  end

end
