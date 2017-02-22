class AddBridgeInfoToLog < ActiveRecord::Migration
  def change
    add_column :qc_logs, :bridge_id, :string
    add_column :qc_logs, :bridge_name, :string
    # Environmental repeating column
    add_column :qc_logs, :environmental_conditions, :string
    add_column :qc_logs, :primer_product, :string
    add_column :qc_logs, :primer_lot_a_number, :string
    add_column :qc_logs, :primer_lot_a_temperature, :string
    add_column :qc_logs, :primer_lot_b_number, :string
    add_column :qc_logs, :primer_lot_b_temperature, :string
    add_column :qc_logs, :primer_gallons_used, :float
    add_column :qc_logs, :primer_application_equipment, :string
    add_column :qc_logs, :primer_spray_gun, :string
    add_column :qc_logs, :primer_spray_module, :string
    add_column :qc_logs, :primer_comments, :text
    # Spray membrane repeating column
    add_column :qc_logs, :spray_membrane_application, :string
    add_column :qc_logs, :application_thickness_instrument, :string
    add_column :qc_logs, :application_thickness_method, :string
    # Repeating application column for value and location
    add_column :qc_logs, :application_value_and_location, :string
    add_column :qc_logs, :adhesion_testing_instrument, :string
    add_column :qc_logs, :adhesion_testing_method, :string
    # Repeating adhesion testing column for value and mode of failure
    add_column :qc_logs, :adhesion_testing_value_and_mode, :string
    add_column :qc_logs, :general_application_comments, :text
    add_column :qc_logs, :sample_retained, :boolean
    add_column :qc_logs, :sample_quantity, :integer
    add_column :qc_logs, :sample_date, :date
    add_column :qc_logs, :sample_sent_by, :string
    add_column :qc_logs, :signature, :string

  end
end
