class Meeting < ActiveRecord::Base
  belongs_to :room
  
  validates_presence_of :room_id, :date
  
  scope :date_desc, -> { order("date desc") }
end
