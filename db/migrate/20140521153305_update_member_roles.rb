class UpdateMemberRoles < ActiveRecord::Migration
  def change
    Member.find_each do |m|
      m.update_columns roles: m.permissions
    end
  end
end
