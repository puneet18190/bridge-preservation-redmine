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

class MailchimpApi
  include Singleton

  def current
    Excon.defaults[:read_timeout] = 180
    Excon.defaults[:ssl_verify_peer] = false
    api_key = Setting.plugin_redmine_crm_mailchimp[:api_key]
    return nil if api_key.blank?
    if @mailchimp_api.nil? || @mailchimp_api.apikey != api_key
      @mailchimp_api = Mailchimp::API.new(api_key)
    end
    @mailchimp_api
  rescue
    return nil
  end

  def self.ping(key)
    Rails.cache.fetch(['MailchimpAPITest', key]) do
      Mailchimp::API.new(key).helper.ping['msg'] == "Everything's Chimpy!"
    end
  rescue
    false
  end
end
