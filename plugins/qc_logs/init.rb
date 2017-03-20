Redmine::Plugin.register :qc_logs do
  name 'Qc Logs plugin'
  author 'Chepri'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.Chepri.com/'
  author_url 'http://www.chepri.com/'
  menu :top_menu, :front_end, "#{Redmine::Configuration['prototype_domain_path']}", :caption => "Front End", last: true

  menu :project_menu, :qc_logs, { controller: 'qc_logs', action: 'index' }, caption: 'QC Logs', last: true, param: :project_id
  require_dependency 'qc_logs_hook_listener'
  project_module :qc_logs do
    permission :view_qc_logs, qc_logs: [:index, :show]
    permission :create_qc_logs, qc_logs: [:create]
    permission :edit_qc_logs, qc_logs: [:update]
  end
end
