class QcLog < ActiveRecord::Base
  unloadable
  belongs_to :project
  belongs_to :user
  scope :visible, lambda {|*args| joins(:project).where(Project.allowed_to_condition(args.first || User.current, :view_qc_logs)) }

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



  def self.text_search(params)
    scope = self.where(nil)
    params.each do |key, value|
      search_key = "with_#{key}_like".to_sym
      scope = scope.send(search_key, value) if scope.respond_to?(search_key) && !value.blank?
    end
    return scope
  end
 end
