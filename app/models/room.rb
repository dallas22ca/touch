class Room < ActiveRecord::Base
  belongs_to :organization
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  has_many :meetings
  
  validates_presence_of :organization_id, :name
end
