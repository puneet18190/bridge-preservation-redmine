class DocumentSerializer < ActiveModel::Serializer
  unloadable

  attributes *Document.attribute_names, :attachments, :category_name
  include Rails.application.routes.url_helpers

 #available event methods
 #[:event_options, :event_options=, :event_datetime, :event_title, :event_description, :event_author, :event_type, :event_date, :event_group, :event_url]
 def category_name
  object.category.name rescue ""
 end

  def attachments
   object.attachments
  end


end
