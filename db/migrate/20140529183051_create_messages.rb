class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :subject
      t.text :body
      t.text :member_ids, default: []
      t.belongs_to :organization, index: true
      t.belongs_to :creator, index: true

      t.timestamps
    end
  end
end
