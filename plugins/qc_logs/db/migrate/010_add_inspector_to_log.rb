class AddInspectorToLog < ActiveRecord::Migration
  def change
    add_column :qc_logs, :inspector, :string
  end
end
