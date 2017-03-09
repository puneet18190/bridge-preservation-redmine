module SearchablePatch
  def self.included(base) # :nodoc:
   

     base.class_eval do 
      unloadable

      columns.map(&:name).uniq.each do |s|
        scope "with_".concat(s).concat("_like").to_sym, -> (param){where("#{table_name}.#{s} ILIKE ?", "%#{param.downcase}%")} if [:string, :text].include?(column_for_attribute(s).type)
     end

    end

    def base.text_search(params)
      scope = self.where(nil)
      params.each do |key, value|
        search_key = "with_#{key}_like".to_sym
        scope = scope.send(search_key, value) if scope.respond_to?(search_key) && !value.blank?
      end
      return scope
     end
   end
  end
 




