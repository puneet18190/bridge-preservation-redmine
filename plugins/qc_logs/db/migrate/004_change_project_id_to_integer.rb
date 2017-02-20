class ChangeProjectIdToInteger < ActiveRecord::Migration
  def change
    change_column :qc_logs, :project_id, 'integer USING CAST(project_id AS integer)'
  end
end
