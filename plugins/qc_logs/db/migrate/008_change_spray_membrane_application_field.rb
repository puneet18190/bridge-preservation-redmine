class ChangeSprayMembraneApplicationField < ActiveRecord::Migration
  def change
    change_column :qc_logs, :spray_membrane_application, "jsonb USING CAST(spray_membrane_application AS jsonb)", default: []
  end
end
