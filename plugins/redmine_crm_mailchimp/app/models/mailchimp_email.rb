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

class MailchimpEmail
  attr_accessor :id, :email

  def initialize(hsh)
    if hsh.is_a? String
      @email = hsh
    else
      @email = hsh['email']
      @id = hsh['id']
    end
  end

  def belongs_to?(list)
    list.id.in? list_ids
  end

  def member_url
    RedmineCrmMailchimp::Settings.member_url(details["web_id"]) unless details["web_id"].blank?
  end

  def location
    [details['geo'].try(:[], 'cc').to_s, details['geo'].try(:[], 'region').to_s].compact.join('/') unless details['geo'].blank?
  end

  def gmap_url
    "http://maps.google.com/maps?q=#{details['geo'].try(:[], 'latitude').to_s},#{details['geo'].try(:[], 'longitude').to_s}"
  end

  def timezone
    details['geo'].try(:[], 'timezone') unless details['geo'].blank?
  end

  def subscribed
    details['timestamp_opt']
  end

  def info_changed
    details['info_changed']
  end

  def language
    details['email'].try(:[], 'language')
  end

  def favorite_email_client
    details['clients'].try(:[], 'name') unless details['clients'].blank?
  end

  def open_rate
    return @open_rate if @open_rate
    opens = campaigns.map{|c| activity_for_campaign(c).any?{|a| a["action"] == "open"} && 1 || 0 rescue 0}.sum
    return nil if campaigns.count == 0
    @open_rate = format('%0.2f', opens.to_f / campaigns.count.to_f * 100.0)
  end

  def opened_campaign?(campaign)
    activity_for_campaign(campaign).any?{ |x| x['action'] == 'open'}
  rescue Mailchimp::ListDoesNotExistError
    false
  end

  def clicked_campaign?(campaign)
    activity_for_campaign(campaign).any?{ |x| x['action'] == 'click'}
  rescue Mailchimp::ListDoesNotExistError
    false
  end

  def click_rate
    return @click_rate if @click_rate
    clicks = campaigns.map{|c| activity_for_campaign(c).any?{|a| a["action"] == "click"} && 1 || 0 rescue 0}.sum
    return nil if campaigns.count == 0
    @clicks_rate = format('%0.2f', clicks.to_f / campaigns.count.to_f * 100.0)
  end

  def rating
    details['member_rating']
  end

  def activity_for_campaign(campaign)
    mailchimp.reports.member_activity(campaign.id, [{:email => @email}])['data'][0]['activity']
  end

  def campaigns
    @campaigns ||= mailchimp.helper.campaigns_for_email(:email => @email).map{ |x| MailchimpCampaign.new(x) }
  rescue
    []
  end

  def details
    @details ||= mailchimp.lists.member_info(list_ids.first, [{:email => @email}])['data'].first rescue {}
  end

  private

  def list_ids
    @list_ids ||= mailchimp.helper.lists_for_email(:email => @email).map{ |x| x['id'] }
  rescue
    []
  end

  def mailchimp
    MailchimpApi.instance.current
  end

end
