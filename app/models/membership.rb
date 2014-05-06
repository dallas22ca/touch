class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  
  before_create :set_initial_admin
  before_create :set_security
  
  def set_initial_admin
    self.security = "admin" if organization.members.empty?
  end
  
  def set_security
    self.security ||= "user"
  end
end
