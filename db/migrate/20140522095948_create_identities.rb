class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.belongs_to :user, index: true
      t.string :provider
      t.string :uid
      t.string :username
      t.string :oauth_token
      t.string :oauth_secret
      t.datetime :oauth_expires_at

      t.timestamps
    end
  end
end
