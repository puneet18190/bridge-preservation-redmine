class InsertCustomFieldsIfNotPresent < ActiveRecord::Migration
  
  def self.up

    file = File.read(Rails.root.to_s + '/plugins/qc_logs/db/custom_field_data.json')
    fields = JSON.parse(file)

    fields.each do |f| 
    	ProjectCustomField.find_or_initialize_by(name: f['name']) do |p|
    		p.attributes = f.reject{|k, v| !ProjectCustomField.attribute_names.include?(k) }
    		p.save
    	end

    end
  end

  def self.down
  	file = File.read(Rails.root.to_s + '/plugins/qc_logs/db/custom_field_data.json')
    fields = JSON.parse(file)
  	
  	ProjectCustomField.where(name: fields.map{|m| m['name'] }).destroy_all
  end
end
