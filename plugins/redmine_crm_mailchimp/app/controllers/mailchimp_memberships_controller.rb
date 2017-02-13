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

class MailchimpMembershipsController < ApplicationController
  before_filter :find_list
  before_filter :find_contact, :except => [:bulk_update, :bulk_edit]
  before_filter :find_contacts, :only => [:bulk_update, :bulk_edit]
  before_filter :find_project, :only => [:create, :destroy]
  before_filter :authorize, :except => [:test_api, :bulk_update, :bulk_edit]

  def create
    @list.subscribe(@contact)
    @notice = I18n.t(:label_mailchimp_subscribed)
  rescue
    @error = $!.message
  end

  def destroy
    @list.unsubscribe(@contact)
    @notice = I18n.t(:label_mailchimp_unsubscribed)
  rescue
    @error = $!.message
  ensure
    render :create
  end

  def bulk_update
    add_to_list = MailchimpList.find_by_id(params[:list_to_add_id])
    remove_from_list = MailchimpList.find_by_id(params[:list_to_remove_id])
    if add_to_list != remove_from_list
      add_to_list.bulk_subscribe(@contacts) if add_to_list
      remove_from_list.bulk_unsubscribe(@contacts.map(&:primary_email)) if remove_from_list
      # @contacts.each do |contact|
      #   add_to_list.subscribe(contact) if add_to_list && contact.email.present?
      #   remove_from_list.unsubscribe(contact) if remove_from_list && contact.email.present?
      # end
    end
    redirect_to contacts_path
  end

  def bulk_edit

  end

  def test_api
    render :json => { :success => MailchimpApi.ping(params[:key]) }
  end

  private

  def find_contact
    @contact = Contact.find(params[:contact_id]) if params[:contact_id]
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_contacts
    @contacts = Contact.where(:id => (params[:contact_id] || params[:contact_ids])).preload(:projects, :avatar, :tags).to_a
    raise ActiveRecord::RecordNotFound if @contacts.empty?
    raise Unauthorized unless @contacts.all?{|c| c.email.present? && c.projects.map{|project|  User.current.allowed_to?(:edit_mailchimp, project)}.any?}
    @projects = @contacts.collect(&:projects).flatten.compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_list
    @list = MailchimpList.find_by_id(params[:list_id])
  end

  def find_project
    project_id = (params[:contact] && params[:contact][:project_id]) || params[:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
