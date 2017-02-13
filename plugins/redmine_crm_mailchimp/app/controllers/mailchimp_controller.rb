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

class MailchimpController < ApplicationController
  before_filter :find_contact, :except => [ :sync ]
  before_filter :find_project, :except => [ :sync ]
  before_filter :check_permission

  def sync
    @query = ContactQuery.find(params[:query_id])
    @query_emails = @query.objects_scope.joins(:projects).where('email IS NOT NULL').where("email <> ''").pluck(:email).map(&:strip)
    @list = MailchimpList.find_by_id(params[:list_id])
    @list_emails = @list.members
    @to_subscribe = @query_emails - @list_emails
    @list.bulk_subscribe(@to_subscribe.map{ |x| Contact.find_by_email(x) }.compact)
    render json: { :success => true }
  end

  private

  def find_contact
    @contact = Contact.find(params[:contact_id])
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def check_permission
    return unless require_login
    if !User.current.allowed_to?(:view_mailchimp, @project)
      render_403
      return false
    end
    true
  end
end
