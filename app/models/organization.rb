class Organization < ActiveRecord::Base
  serialize :modules, Array

  has_many :memberships
  has_many :members, through: :memberships, source: :user
  has_many :rooms
  has_many :events
  
  validates_uniqueness_of :permalink
  
  def to_param
    permalink
  end
end
