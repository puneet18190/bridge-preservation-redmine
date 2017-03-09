Redmine::Plugin.register :rm_user_mentions do
  name 'Redmine User Mentions plugin'
  author 'Kovalevsky Vasil'
  description ''
  version '1.0.0'
  url 'http://rmplus.pro/redmine/plugins/user_mentions'
  author_url 'http://rmplus.pro/'

  settings partial: 'rum/settings', default: { 'min_chars_for_mentions' => 3, 'mentions_magic_char' => '@', 'mentions_myself_link' => 'I', 'fields_with_mentions' => '#issue_description, .wiki-edit' }

  Redmine::WikiFormatting::Macros.register do
    macro :rum do |obj, args|
      return '' if args.length < 1
      entry_id = args[0].strip
      begin
        user = User.find(entry_id.to_i)
        if user
          title = args[1] ? args[1] : user.name
          if Redmine::Plugin.installed?(:ldap_users_sync)
            return link_to_user(user, name: title)
          else
            return (user.active? ? link_to("<span>#{title}</span>".html_safe, user_path(user), class: user.css_classes) : title).html_safe
          end
        end
      rescue ActiveRecord::RecordNotFound
        return "<span class='rum-not-found'>#{l(:rum_label_not_found_user)}</span>".html_safe
      end
    end

  end
end

Rails.application.config.after_initialize do
  plugins = { a_common_libs: '2.1.0' }
  plugin = Redmine::Plugin.find(:rm_user_mentions)
  plugins.each do |k,v|
    begin
      plugin.requires_redmine_plugin(k, v)
    rescue Redmine::PluginNotFound => ex
      raise(Redmine::PluginNotFound, "Plugin requires #{k} not found")
    end
  end
end

require 'rum/view_hooks'