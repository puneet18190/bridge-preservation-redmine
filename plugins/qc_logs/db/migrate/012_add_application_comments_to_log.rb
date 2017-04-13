class AddApplicationCommentsToLog < ActiveRecord::Migration
  def change
    add_column :qc_logs, :application_comments, :string
  end
end
