class ProjectMemberSerializer < ActiveModel::Serializer
  unloadable

  attributes *User.attribute_names.reject{|r| ['hashed_password', 'salt', 'admin'].include?(r) }
  include Rails.application.routes.url_helpers


end
