module Redmine::FieldFormat
  class Base
    class_attribute :ajax_supported
    self.ajax_supported = false

    attr_accessor :lb_only_current
  end

  class UserFormat
    self.ajax_supported = true

    def possible_values_records(custom_field, object=nil, like=nil, vals=nil)
      if object.is_a?(Array)
        projects = object.map {|o| o.respond_to?(:project) ? o.project : nil}.compact.uniq
        scope = User.active.joins(:members).where("#{Member.table_name}.project_id in (?)", projects.map { |p| p.project.id } + [0]).uniq
      elsif object.respond_to?(:project) && object.project
        scope = User.active.joins(:members).where("#{Member.table_name}.project_id = ?", object.project.id).uniq
      else
        scope = nil
      end

      return [] if scope.nil?

      if custom_field.user_role.is_a?(Array)
        role_ids = custom_field.user_role.map(&:to_s).reject(&:blank?).map(&:to_i)
        if role_ids.any?
          scope = scope.where("#{Member.table_name}.id IN (SELECT DISTINCT member_id FROM #{MemberRole.table_name} WHERE role_id IN (?))", role_ids)
        end
      end

      if vals.present?
        scope = scope.sorted.where(id: vals)
      elsif like.present?
        scope = scope.sorted.like(like)
      end

      if block_given?
        scope.each do |it|
          yield(it, it.id, it.name)
        end
      end

      scope.sorted
    end
  end

  class RecordList

    def select_edit_tag(view, tag_id, tag_name, custom_value, options={})
      if custom_value.custom_field.format.ajax_supported && custom_value.custom_field.ajaxable
        options[:class] = options[:class].to_s + ' acl-select2-ajax'

        current_values = Array.wrap(custom_value.value)
        current_options = []
        if current_values.present?
          if self.respond_to?(:current_values_options)
            current_options = current_values_options(custom_value)
          else
            current_options = possible_custom_value_options(custom_value).select { |it| current_values.include?(it[1].to_s) } || []
          end
        end

        options[:data] ||= {}
        options[:data] = options[:data].merge({ url: view.url_for(controller: :custom_fields, action: :ajax_values, id: custom_value.custom_field.id),
                                                project_id: custom_value.customized.try(:project).try(:id).to_i,
                                                customized_id: custom_value.customized.try(:id).to_i
                                              })
        current_options = (custom_value.custom_field.multiple? ? [] : [['', '']]) + current_options unless custom_value.required?
        s = view.select_tag(tag_name, view.options_for_select(current_options, custom_value.value), options.merge(id: tag_id, multiple: custom_value.custom_field.multiple?, placeholder: ' '))
        if custom_value.custom_field.multiple?
          s << view.hidden_field_tag(tag_name, '')
        end
        s
      else
        super(view, tag_id, tag_name, custom_value, options)
      end
    end

    def current_values_options(custom_value)
      options = Array.wrap(custom_value.value)

      if self.respond_to?(:possible_values_records)
        res = []
        possible_values_records(custom_value.custom_field, custom_value.customized, nil, options) { |it, id, value| res << [value, id] }
        res
      else
        target_class.where(id: options.map(&:to_i)).map { |o| [o.to_s, o.id.to_s] }
      end
    end
  end
end