# This file is a part of Redmine Products (redmine_products) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2017 RedmineUP
# http://www.redmineup.com/
#
# redmine_products is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_products is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_products.  If not, see <http://www.gnu.org/licenses/>.

class OrderObserver < ActiveRecord::Observer
  def after_create(order)
    ProductsMailer.order_added(order).deliver if Setting.notified_events.include?('products_order_added')
  end
  def after_update(order)
    ProductsMailer.order_updated(order).deliver if (order.status_id_changed? || order.amount_changed?) && Setting.notified_events.include?('products_order_updated')
  end
end
