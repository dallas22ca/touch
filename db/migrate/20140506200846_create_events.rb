class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description
      t.hstore :data
      t.text :json_data
      t.belongs_to :organization, index: true
      t.belongs_to :member, index: true

      t.timestamps
    end
  end
end
