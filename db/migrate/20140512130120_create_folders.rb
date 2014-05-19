class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
