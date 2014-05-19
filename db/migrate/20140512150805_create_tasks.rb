class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :content
      t.belongs_to :folder, index: true
      t.belongs_to :creator, index: true

      t.timestamps
    end
  end
end
