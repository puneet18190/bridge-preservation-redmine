module Acl::Patches::Models
  module IssuePatch
    if Redmine::VERSION.to_s >= '3.0.0'
      def self.included(base)
        base.extend(ClassMethods)

        base.class_eval do
          class << self
            alias_method_chain :allowed_target_projects, :acl
          end
        end
      end

      module ClassMethods
        def allowed_target_projects_with_acl(user=User.current, current_project=nil)
          sc = allowed_target_projects_without_acl(user, current_project)
          fp = user.favourite_project
          if fp.present?
            sc.order("case when #{Project.table_name}.id = #{fp.id} then 0 else 1 end")
          else
            sc
          end
        end
      end
    end
  end
end