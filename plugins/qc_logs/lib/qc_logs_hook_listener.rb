class PollsHookListener < Redmine::Hook::ViewListener
  def view_projects_show_left(context = {})
    return content_tag("p", "Custom content added to the left")
  end

end
