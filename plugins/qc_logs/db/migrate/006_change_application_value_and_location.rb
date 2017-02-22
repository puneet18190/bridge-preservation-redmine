class ChangeApplicationValueAndLocation < ActiveRecord::Migration
  def change
    change_column :qc_logs, :application_value_and_location, "jsonb USING CAST(application_value_and_location AS jsonb)", default: '[]'
  end
end
