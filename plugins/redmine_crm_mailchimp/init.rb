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

Redmine::Plugin.register :redmine_crm_mailchimp do
  name 'RedmineUP Mailchimp plugin'
  author 'RedmineUP'
  description 'This is a plugin for RedmineUP to integrate MailChimp mailing sevice with contacts'
  version '1.0.2'
  url 'http://redmineup.com/pages/extensions_mailchimp'
  author_url 'mailto:support@redmineup.com'

  begin
    requires_redmine_plugin :redmine_contacts, :version_or_higher => '3.3.0'
  rescue Redmine::PluginNotFound  => e
    raise "Please install redmine_contacts plugin"
  end

  menu :admin_menu, :mailchimp_settings, {:controller => 'settings', :action => 'plugin', :id => :redmine_crm_mailchimp}, :caption => :label_mailchimp_settings

  settings :default => {
    :api_key => ''
  }, :partial => 'settings/mailchimp/mailchimp'
  project_module :mailchimp do
    permission :view_mailchimp, { :mailchimp_memberships => :show, :mailchimp => [:lists, :campaigns] }
    permission :edit_mailchimp, { :mailchimp_memberships => [ :edit, :destroy, :create, :bulk_update, :bulk_edit, :test_api ], :mailchimp => [:lists, :campaigns] }
  end
end

require 'redmine_crm_mailchimp'
