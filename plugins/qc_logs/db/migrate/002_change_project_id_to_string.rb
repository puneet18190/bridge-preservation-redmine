class ChangeProjectIdToString < ActiveRecord::Migration
  def change
    change_column :qc_logs, :project_id, :string
  end
end
