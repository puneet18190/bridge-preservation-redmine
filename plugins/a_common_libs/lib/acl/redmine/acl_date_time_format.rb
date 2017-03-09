module Redmine::FieldFormat
  class AclDateTimeFormat < Unbounded
    add 'acl_date_time'
    self.form_partial = 'a_common_libs/formats/date_time'

    def cast_single_value(custom_field, value, customized=nil)
      if value.is_a?(String) && value.present? && ActiveRecord::Base.default_timezone == :utc
        value = value.strip + ' UTC'
      end
      Time.parse(value) rescue nil
    end

    def validate_single_value(custom_field, value, customized=nil)
      if (value =~ /^\d{4}-\d{2}-\d{2} \d{1,2}:\d{2}:\d{2}$|^\d{4}-\d{2}-\d{2} \d{1,2}:\d{2}$/ && (value.to_datetime rescue false))
        []
      else
        [::I18n.t('activerecord.errors.messages.not_a_date')]
      end
    end

    def edit_tag(view, tag_id, tag_name, custom_value, options={})
      view.text_field_tag(tag_name, User.current.acl_server_to_user_time(custom_value.value), options.merge(:id => tag_id, :size => 10)) +
          view.calendar_for_time(tag_id)
    end

    def bulk_edit_tag(view, tag_id, tag_name, custom_field, objects, value, options={})
      view.text_field_tag(tag_name, User.current.acl_server_to_user_time(value), options.merge(:id => tag_id, :size => 10)) +
          view.calendar_for_time(tag_id) +
          bulk_clear_tag(view, tag_id, tag_name, custom_field, value)
    end

    def query_filter_options(custom_field, query)
      {:type => :acl_date_time}
    end

    def group_statement(custom_field)
      order_statement(custom_field)
    end

    def value_to_save(value)
      if (tm = User.current.acl_user_to_server_time(value))
        tm.strftime('%Y-%m-%d %H:%M:%S')
      end
    end
  end
end