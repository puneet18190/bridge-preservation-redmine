Redmine::Plugin.register :api_extensions do
  name 'api extensions plugin'
  author 'Chepri'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://www.Chepri.com/'
  author_url 'http://www.chepri.com/'

  #permission :view_qc_logs, qc_logs: :index
  #menu :project_menu, :qc_logs, { controller: 'qc_logs', action: 'index' }, caption: 'QC Logs', last: true, param: :project_id
end
