class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization
  
  before_create :set_initial_admin
  before_create :set_security

  validates_uniqueness_of :key, scope: :organization
  
  before_save :set_key
  
  def set_key
    self.key ||= id.to_s
  end
  
  def set_initial_admin
    self.security = "admin" if organization.members.empty?
  end
  
  def set_security
    self.security ||= "user"
  end
end
