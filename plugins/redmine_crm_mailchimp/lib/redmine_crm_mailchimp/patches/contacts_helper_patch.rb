# This file is a part of Redmine Mailchimp (redmine_crm_mailchimp) plugin,
# mailchimp integration plugin for Redmine
#
# Copyright (C) 2011-2016 RedmineUP
# http://www.redmineup.com/
#
# redmine_crm_mailchimp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_crm_mailchimp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_crm_mailchimp.  If not, see <http://www.gnu.org/licenses/>.

module RedmineCrmMailchimp
  module Patches
    module ContactsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :contact_tabs, :mailchimp
        end
      end


      module InstanceMethods

        def contact_tabs_with_mailchimp(contact)
          tabs = contact_tabs_without_mailchimp(contact)

          if contact.email.present? &&
            Setting.plugin_redmine_crm_mailchimp[:api_key].present? &&
            User.current.allowed_to?(:view_mailchimp, @project)
            tabs.push({:name => 'mailchimp', :partial => 'mailchimp/contact_tab', :label => l(:label_mailchimp)})
          end
          tabs
        end

      end

    end
  end
end

unless ContactsHelper.included_modules.include?(RedmineCrmMailchimp::Patches::ContactsHelperPatch)
  ContactsHelper.send(:include, RedmineCrmMailchimp::Patches::ContactsHelperPatch)
end
