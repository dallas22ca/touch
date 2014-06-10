class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.belongs_to :sequence, index: true
      t.integer :offset
      t.string :action
      t.belongs_to :task, index: true
      t.belongs_to :message, index: true

      t.timestamps
    end
  end
end
