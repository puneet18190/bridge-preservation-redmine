class QcLogsController < ApplicationController
  unloadable


  def index
    @qc_logs = QcLog.where(project_id: params[:project_id])
  end


end
