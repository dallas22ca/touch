class Organization < ActiveRecord::Base
  serialize :modules, Array

  has_many :members
  has_many :users, through: :members
  has_many :rooms
  has_many :events
  
  validates_uniqueness_of :permalink
  
  def to_param
    permalink
  end
end
