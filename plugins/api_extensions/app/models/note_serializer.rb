class NoteSerializer < ActiveModel::Serializer
  unloadable

  attributes *Message.attribute_names, :replies, :attachments
  include Rails.application.routes.url_helpers

 #available event methods
 #[:event_options, :event_options=, :event_datetime, :event_title, :event_description, :event_author, :event_type, :event_date, :event_group, :event_url]

  def replies
   replies = Message.where(parent_id: object.id)
   replies.order(updated_on: :desc)
   replies = ActiveModel::Serializer::CollectionSerializer.new(replies, serializer: ActiveModel::Serializer::NoteSerializer)
  end

  def attachments
  	object.attachments
  end


end
