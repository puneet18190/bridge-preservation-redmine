class QcLogsController < ApplicationController
  unloadable
  before_action :begin_of_assocation_chain

  def index
        if params[:project_id]
          project = Project.find_by(identifier: params[:project_id])
          project_id = project.id
          return @qc_logs = @qc_logs.where(:project_id => project_id)
        end
  end

  private

    def begin_of_assocation_chain
      if User.current.admin?
        @qc_logs = QcLog.all
      else
        @qc_logs = QcLog.where(user_id: User.current.id)
      end

    end

end
