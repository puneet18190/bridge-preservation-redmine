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
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        stylesheet_link_tag(:redmine_crm_mailchimp, :plugin => 'redmine_crm_mailchimp') +
            javascript_include_tag(:redmine_crm_mailchimp, :plugin => 'redmine_crm_mailchimp')
      end
    end
  end
end
