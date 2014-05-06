class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.belongs_to :organization, index: true

      t.timestamps
    end
  end
end
