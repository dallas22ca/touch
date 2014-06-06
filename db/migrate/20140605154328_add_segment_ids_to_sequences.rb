class AddSegmentIdsToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :segment_ids, :text, default: []
  end
end
