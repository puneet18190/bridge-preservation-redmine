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

class MailchimpList
  attr_accessor :id, :name, :member_count, :open_rate, :click_rate, :date_created, :date_added, :web_id

  def self.all
    Rails.cache.fetch('MailchimpList::self::all', expires_in: 2.seconds) do
      return [] unless mailchimp
      mailchimp.lists.list['data'].map{ |x| MailchimpList.new(x) }
    end
  end

  def self.subscribable_for(user)
    all.select{ |x| !user.belongs_to? x }
  end

  def self.subscribed_by(user)
    all.select{ |x| user.belongs_to? x }
  end

  def self.exists?(id)
    all.any?{ |x| x.id == id }
  end

  def initialize(hsh)
    @web_id = hsh['web_id']
    @name = hsh['name']
    @id = hsh['id']

    if hsh['stats']
      @member_count = hsh['stats']['member_count']
      @open_rate = hsh['stats']['open_rate']
      @click_rate = hsh['stats']['click_rate']
    end
    @date_created = hsh['date_created']
    @date_added = hsh['date_added']
  end

  def self.find_by_id(id)
    all.find{ |x| x.id == id }
  end

  def subscribe(contact)
    merge_vars = { :"FNAME" => contact.first_name.to_s.strip, :"LNAME" => contact.last_name.to_s.strip }
    self.class.mailchimp.lists.subscribe(@id, { :email => contact.email.strip }, merge_vars, :html, false)
  rescue
    Rails.logger.info $!.message
  end

  def unsubscribe(contact)
    self.class.mailchimp.lists.unsubscribe(@id, { :email => contact.email })
  rescue
    Rails.logger.info $!.message
  end

  def bulk_subscribe(contacts)
    contacts = contacts.map do |x|
      {
        :email => { :email => x.email },
        :merge_vars => { :"FNAME" => x.first_name.to_s.strip, :"LNAME" => x.last_name.to_s.strip }
      }
    end
    self.class.mailchimp.lists.batch_subscribe(@id, contacts, false)
  end

  def bulk_unsubscribe(emails)
    self.class.mailchimp.lists.batch_unsubscribe(@id, emails.map{ |x| { :email => x} })
  end

  def members
    self.class.mailchimp.lists.members(@id)['data'].map{ |x| x['email'] }
  end

  private

  def self.mailchimp
    MailchimpApi.instance.current
  end
end
