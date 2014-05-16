class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
