class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.string :strategy
      t.belongs_to :creator, index: true
      t.integer :interval
      t.datetime :date
      t.belongs_to :organization, index: true

      t.timestamps
    end
  end
end
