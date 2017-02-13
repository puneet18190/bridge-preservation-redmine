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

require File.expand_path('../../test_helper', __FILE__)

class MailchimpApiTest < ActiveSupport::TestCase

  def test_instance
    # You must provide a MailChimp API key
    Setting.plugin_redmine_crm_mailchimp[:api_key] = nil
    assert_equal nil, MailchimpApi.instance.current
    
    # Your MailChimp API key must contain a suffix subdomain (e.g. "-us8").
    Setting.plugin_redmine_crm_mailchimp[:api_key] = 'sw8'
    assert_equal nil, MailchimpApi.instance.current

    Setting.plugin_redmine_crm_mailchimp[:api_key] = '123abc-sw8'
    assert_equal Mailchimp::API, MailchimpApi.instance.current.class    
  end

end
