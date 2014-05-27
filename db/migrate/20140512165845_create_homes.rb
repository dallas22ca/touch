class CreateHomes < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.string :address
      t.string :city
      t.string :province
      t.string :postal_code
      t.string :beds
      t.string :baths
      t.text :data, default: "{}"
      t.belongs_to :folder, index: true
      t.belongs_to :creator, index: true

      t.timestamps
    end
  end
end
