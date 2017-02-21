class QcLogsController < ApplicationController
  unloadable
  before_action :begin_of_assocation_chain

  def index
    respond_to do |format|
      format.html {
        if params[:project_id]
          return @qc_logs = @qc_logs.where(:project_id => params[:project_id])
        else
          return @qc_logs
        end
      }
      format.json  {
        if params[:project_id]
          return @qc_logs = @qc_logs.where(:project_id => params[:project_id])
        else
          return @qc_logs
        end #where(project_id: params[:project_id])
      }
    end
  end

  def create(params)
    @qc_log = QcLog.create(params)
    if @qc_log.save
      flash[:success] = "Successfully created a QC Log"
    else
      flash[:danger] = "An Error Occurred"
    end

  end

  def show
    @qc_log = @qc_logs.find(params[:id])
  end



  private

  def begin_of_assocation_chain
    @qc_logs = QcLog.where(user_id: User.current.id)
  end


end
