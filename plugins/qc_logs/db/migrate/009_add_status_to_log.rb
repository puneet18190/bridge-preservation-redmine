class AddStatusToLog < ActiveRecord::Migration
  def change
    add_column :qc_logs, :status, :string
  end
end
