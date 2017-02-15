class CreateQcLogs < ActiveRecord::Migration
  def change
    create_table :qc_logs do |t|
      t.datetime "date"
      t.string   "project"
      t.string   "approved_applicator"
      t.float    "square_footage"
      t.string   "location_name"
      t.string   "location_latitude"
      t.string   "location_longitude"
      t.datetime "environmental_time"
      t.string   "environmental_temp"
      t.string   "environmental_wind_velocity"
      t.string   "environmental_substrate_temp"
      t.string   "environment_substrate_moisture"
      t.string   "environmental_dew_point"
      t.text     "environmental_description"
      t.float    "substrate_square_footage"
      t.string   "substrate_equipment"
      t.string   "substrate_surface_preparation_standard"
      t.string   "substrate_profile"
      t.string   "substrate"
      t.string   "substrate_media"
      t.text     "substrate_general_comments"
      t.integer  "user_id"
      t.integer  "project_id"

      t.timestamps
    end
  end
end
