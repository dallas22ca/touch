class Meeting < ActiveRecord::Base
  belongs_to :room
  
  validates_presence_of :room_id, :date
  
  scope :date_desc, -> { order("date desc") }
  
  def events(pluck_member_ids = false)
    events = Event
    events = events.where("data @> 'meeting.id=>#{id}'")
    events = events.pluck(:member_id) if pluck_member_ids
    events
  end
end
