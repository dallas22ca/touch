class AddSegmentIdsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :segment_ids, :text, default: []
  end
end
