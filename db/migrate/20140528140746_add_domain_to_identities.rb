class AddDomainToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :domain, :string
  end
end
