class CreateBitlies < ActiveRecord::Migration
  def change
    create_table :bitlies do |t|
      t.string :token
      t.string :href

      t.timestamps
    end
  end
end
