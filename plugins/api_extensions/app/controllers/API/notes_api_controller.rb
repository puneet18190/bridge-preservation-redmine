class Api::NotesApiController < Api::ApplicationController
  
  before_action ->(controller='projects', action=params[:action] ){authorize(controller, action, true)}, :except => [:list, :new, :create, :copy, :archive, :unarchive, :destroy]

  #before_filter :authorize

  accept_rss_auth :index
  accept_api_auth :index
  require_sudo_mode :destroy


  helper :custom_fields
  helper :issues
  helper :queries
  helper :repositories
  helper :members 


  # Lists visible projects
 def index
    project_scope = Project.visible.find(params[:project_id]) rescue nil
    
    begin
     board = Board.find_by(project_id: project_scope.id) 
    rescue  ActiveRecord::RecordNotFound 
      board = Board.new
    end

    @notes = board.topics.includes(:attachments)
    #for now on #.where(project_id: Project.visible.find(params[:project_id])).includes(:attachments) rescue []

    
    
    @notes = paginate @notes, per_page: params[:per_page], page: params[:page]
    render json: {notes: ActiveModel::Serializer::CollectionSerializer
      .new(@notes, serializer: ActiveModel::Serializer::NoteSerializer,
        user: User.current) }
 end

  private 





end