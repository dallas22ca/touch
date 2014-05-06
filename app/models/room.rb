class Room < ActiveRecord::Base
  belongs_to :organization
  has_many :meetings
  
  validates_presence_of :organization_id, :name
end
