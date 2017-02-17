class ProjectSerializer < ActiveModel::Serializer
  #unloadable

  attributes *Project.attribute_names, :activities, :custom_fields



  def activities
    from = instance_options[:from]
    to = instance_options[:to]
    limit = instance_options[:limit]
    if instance_options[:include_activities]
     Redmine::Activity::Fetcher.new(instance_options[:user], :project => object).events(from, to, {:limit=>limit })
    end
  end

  def custom_fields
    fields = CustomValue.where(customized_type: 'Project').where(customized_id: object.id).includes(:custom_field)
    return fields.map{|m| 
      {
        :id => m.id,
        :name => m.custom_field.name,
        :value => m.value,

      }
    }

  end


end
