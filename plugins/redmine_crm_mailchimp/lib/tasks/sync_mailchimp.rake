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

namespace :redmine do
  namespace :mailchimp do
    desc 'Synchronizes all saved contact query to mailchimp lists assigned'
    task :sync_queries => :environment do
      RedmineCrmMailchimp::Settings.new.assignments.each do |assignment|
        User.current = User.where(admin: true).first
        @query = ContactQuery.find(assignment[:contact_query_id])
        @query_emails = @query.objects_scope.joins(:projects).where('email IS NOT NULL').where("email <> ''")
        @list = MailchimpList.find_by_id(assignment[:mailchimp_id])
        puts "Processing query #{@query.name} id: #{@query.id} assigned to list #{@list.name}"
        @list_emails = @list.members
        @to_subscribe = @query_emails - @list_emails
        subscribed = @list.bulk_subscribe(@to_subscribe)['add_count']
        puts "Subscribed #{subscribed} new emails"
      end
    end
  end
end
