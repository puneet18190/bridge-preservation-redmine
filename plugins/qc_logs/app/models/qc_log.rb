class QcLog < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :user
  scope :visible, lambda {|*args| joins(:project).where(Project.allowed_to_condition(args.first || User.current, :view_qc_logs)) }

  acts_as_event :title  => Proc.new {|o| "#{l(:label_document)}: #{o.title}"},
                :author => Proc.new {|o| User.try(:find, o.id) },
                :url => Proc.new {|o| {:controller => 'qc_logs', :action => 'show', :id => o.id}}
  acts_as_activity_provider :scope => preload(:project)
  #define partial match text searches for text columns
  columns.map(&:name).uniq.each do |s|

    scope "with_".concat(s).concat("_like").to_sym, -> (param){where("#{table_name}.#{s} ILIKE ?", "%#{param.downcase}%")} if [:string, :text].include?(column_for_attribute(s).type)
    scope "with_".concat(s).concat('_between').to_sym, -> (from=Date.today, to = nil)  {
      params = {}
      params[:from] = from
      params[:to] = to if to 
      second_clause = "AND #{table_name}.#{s} <= :to" if params[:to]
      where("#{table_name}.#{s} >=  :from #{second_clause} ", params)} if [:date, :datetime].include?(column_for_attribute(s).type)
  end



  #association searches

  self.reflect_on_all_associations.map(&:name).each do |s| 
    s = s.to_s
    assoc_table_name = s.classify.constantize.table_name
    scope "has_".concat(s).concat("_with_id").to_sym, -> (id){includes(s.to_sym).where("#{assoc_table_name}.id = ?", id).references(assoc_table_name) }
  end

  def self.visible_extended
    scope = self.visible.where.not(status: 'Draft')
    draft_scope = scope.unscope(:where, :joins).where(status: 'Draft')


    current_user_groups = User.current.groups.select{|g| !g.memberships.empty?}
    roles = User.current.projects_by_role.keys.map(&:name)
    not_user_ids = []
    
    if roles.include?('Applicator')
      users  = User.where(id: scope.collect{|c| c.user_id}.flatten - [User.current.id])


      user_id_and_roles = users.collect{|u| {user: u,  role_names: u.projects_by_role.keys.map(&:name) }}.flatten
  

      not_users = user_id_and_roles.flatten.select{|s| s[:role_names].include?('Applicator')}.map{|m| m[:user]}
      


      not_users.each do |u|
        user_groups = u.groups.select{|g| !g.memberships.empty? }

        unless !(current_user_groups.map(&:id) & user_groups.map(&:id) ).empty?
          not_user_ids << u.id 
        end
      end
     end


      scope = scope.where.not(user_id: not_user_ids) if !not_user_ids.empty?
      
      unless User.current.admin
        draft_scope = draft_scope.where(user_id: User.current.id)
      end

      return QcLog.from("(#{scope.to_sql} UNION ALL #{draft_scope.to_sql}) as qc_logs")
    
    
  end

  def self.text_search(params)
    scope = self.where(nil)
    params.each do |key, value|
      search_key = "with_#{key}_like".to_sym
      scope = scope.send(search_key, value) if scope.respond_to?(search_key) && !value.blank?
    end
    return scope
  end
 end
