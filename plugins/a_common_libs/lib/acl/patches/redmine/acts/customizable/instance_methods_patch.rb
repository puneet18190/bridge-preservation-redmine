module Acl::Patches::Redmine::Acts::Customizable
  module InstanceMethodsPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :custom_field_values=, :acl
        attr_accessor :acl_edit_custom_field_values
      end
    end

    module InstanceMethods
      def custom_field_values_with_acl=(vl)
        self.acl_edit_custom_field_values = true

        begin
          send :custom_field_values_without_acl=, vl
        ensure
          self.acl_edit_custom_field_values = false
        end
      end
    end
  end
end