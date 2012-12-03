class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string  :name
      t.string  :longitude
      t.string  :latitude

      t.timestamps
    end
  end
end
