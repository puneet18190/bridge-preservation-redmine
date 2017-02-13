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

resources :mailchimp_memberships, :only => [:create] do
  collection do
    delete '', :action => :destroy
    get :bulk_edit
    post :bulk_update
    get :test_api
  end
end

get 'mailchimp/lists/:project_id/:contact_id', :action => :lists, :controller => :mailchimp
get 'mailchimp/campaigns/:project_id/:contact_id', :action => :campaigns, :controller => :mailchimp
get 'mailchimp/details/:project_id/:contact_id', :action => :details, :controller => :mailchimp
get 'mailchimp/sync/:query_id/with/:list_id', :action => :sync, :controller => :mailchimp
