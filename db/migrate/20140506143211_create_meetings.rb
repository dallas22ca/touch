class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.belongs_to :room, index: true
      t.datetime :date

      t.timestamps
    end
  end
end
