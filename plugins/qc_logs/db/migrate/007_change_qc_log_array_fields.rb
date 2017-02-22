class ChangeQcLogArrayFields < ActiveRecord::Migration
  def change
    change_column :qc_logs, :adhesion_testing_value_and_mode, "jsonb USING CAST(adhesion_testing_value_and_mode AS jsonb)", default: []
    change_column :qc_logs, :environmental_conditions, "jsonb USING CAST(environmental_conditions AS jsonb)", default: []
  end
end
