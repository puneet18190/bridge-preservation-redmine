class PollsHookListener < Redmine::Hook::ViewListener
	require 'redmine'


  def view_projects_show_left(context = {})
  	return content_tag("p",  (link_to "View Project", "#{Redmine::Configuration['prototype_domain_path']}/projects/#{context[:project].id}", class: "btn btn-orange", target: "_blank"))
  end

end
