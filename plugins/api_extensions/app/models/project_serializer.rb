class ProjectSerializer < ActiveModel::Serializer
  unloadable

  attributes *Project.attribute_names, :activities, :custom_fields, :products
  include Rails.application.routes.url_helpers

 #available event methods
 #[:event_options, :event_options=, :event_datetime, :event_title, :event_description, :event_author, :event_type, :event_date, :event_group, :event_url]

  def activities
    events = []
    from = instance_options[:from]
    to = instance_options[:to]
    limit = instance_options[:limit]
    if instance_options[:include_activities]

     event_fetch =  Redmine::Activity::Fetcher.new(instance_options[:user], :project => object).events(from, to, {:limit=>limit })
     event_fetch.each do |e|
      e_hash = e.attributes 
      e_hash[:event_type] = e.event_type
      e_hash[:event_datetime] = e.event_datetime
      e_hash[:event_author] = e.event_author.attributes.slice("firstname", "lastname", "id") rescue {"firstname": "", "lastname": "", "id": ""}
      e_hash[:event_description] = e.event_description
      e_hash[:event_group] = e.event_group
      e_hash[:event_url] = url_for(e.event_url.merge(:only_path => true)) rescue ""
      e_hash[:event_title] = e.event_title
      
      events << e_hash
     end
    end
    return events
  end

  def custom_fields
    custom_fields = ProjectCustomField.all
    custom_field_hash = {}
    #fields = CustomValue.where(customized_type: 'Project').where(customized_id: object.id).includes(:custom_field)
   custom_fields.each do |m| 
    custom_value = CustomValue.where(customized_type: 'Project', custom_field_id: m.id).where(customized_id: object.id).first ||  CustomValue.new
      custom_field_hash[m.name.to_sym] = {
        :id => custom_value.id,
        :value => custom_value.value
       }

    end
    return custom_field_hash



  end

  def products
    object.products
  end
end

