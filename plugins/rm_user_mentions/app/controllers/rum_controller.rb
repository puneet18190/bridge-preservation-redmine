class RumController < ApplicationController
  def user_autocomplete
    value = params[:value].to_s

    users_list = []
    if value.size >= (Setting.plugin_rm_user_mentions['min_chars_for_mentions'] || 3).to_i
      users_list = User.like(value).sorted.active.map { |u| { id: u.id, name: u.name, email: u.mail, login: u.login, avatar: view_context.avatar(u, size: '14') } }
    end
    if value == Setting.plugin_rm_user_mentions['mentions_myself_link']
      users_list << { id: User.current.id, name: User.current.name, email: User.current.mail, login: User.current.login, avatar: view_context.avatar(User.current, size: '14') }
    end

    render json: { users: users_list }
  end
end