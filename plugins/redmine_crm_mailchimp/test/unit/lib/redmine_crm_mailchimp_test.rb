# encoding: utf-8
#
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

require File.expand_path('../../../test_helper', __FILE__)

class RedmineCrmMailchimpTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :queries
  fixtures :email_addresses if ActiveRecord::VERSION::MAJOR >= 4

  RedmineContacts::TestCase.create_fixtures(Redmine::Plugin.find(:redmine_contacts).directory + '/test/fixtures/', [:contacts,
                                                                                                                    :contacts_projects,                                                                                                                    
                                                                                                                    :queries])  
  def setup
    Setting.plugin_redmine_crm_mailchimp['mailchimp_query_assignments'] = [{ :contact_query_id => 4 }, { :contact_query_id => 5 }]
    @redmine_crm_mail_chimp = RedmineCrmMailchimp::Settings.new
  end

  def test_visible_queries
    assert_equal [4,5,3].sort , @redmine_crm_mail_chimp.visible_queries.map(&:id).sort
  end

end
