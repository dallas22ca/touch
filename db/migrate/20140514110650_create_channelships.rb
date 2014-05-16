class CreateChannelships < ActiveRecord::Migration
  def change
    create_table :channelships do |t|
      t.belongs_to :channel, index: true
      t.belongs_to :member, index: true
      t.string :role

      t.timestamps
    end
  end
end
