class QcLogSerializer < ActiveModel::Serializer
  unloadable

  attributes *QcLog.attribute_names, :owner, :project_name


  def owner
    contacts, custom_values = [instance_options[:contacts], instance_options[:custom_values]]
    value = custom_values.select{|s| s.customized_id == object.project_id}.first
    owner = contacts.select{|s| s.id == value.value.try(:to_i) }.first.try(:first_name) if value
    owner

  end

  def project_name
    object.project.try(:name)
  end

end
