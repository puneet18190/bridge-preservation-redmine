class DocumentSerializer < ActiveModel::Serializer
  unloadable

  attributes *Document.attribute_names, :attachments, :category_name, :user
  include Rails.application.routes.url_helpers

 #available event methods
 #[:event_options, :event_options=, :event_datetime, :event_title, :event_description, :event_author, :event_type, :event_date, :event_group, :event_url]
 def category_name
  object.category.name rescue ""
 end

  def attachments
   object.attachments
  end

  def user
    user_h = {}
    user_id = attachments.first.author_id rescue nil
    user = User.find(user_id) rescue nil
    if user
     user_h['id'] = user.id
     user_h['email'] = user.mail
     user_h['firstname'] = user.firstname
     user_h['lastname'] = user.lastname
    end
    return user_h
  end

end
