module Acl::Patches::Models
  module CustomFieldValuePatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        alias_method_chain :value=, :acl
      end
    end

    module InstanceMethods
      def value_with_acl=(vl)
        if self.custom_field.format.respond_to?(:value_to_save) && self.customized.acl_edit_custom_field_values && self.value != self.value_was
          vl = self.custom_field.format.value_to_save(vl)
        end
        send :value_without_acl=, vl
      end
    end
  end
end