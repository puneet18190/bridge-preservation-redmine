class ProjectMemberSerializer < ActiveModel::Serializer
  unloadable

  attributes *User.attribute_names.reject{|r| ['hashed_password', 'salt', 'admin'].include?(r) }, :membership_id
  include Rails.application.routes.url_helpers


  def membership_id
    project = instance_options[:project]
    membership = project.memberships.find_by(user_id: object.id) rescue nil
    return membership.id

  end

end
