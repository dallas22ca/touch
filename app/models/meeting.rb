class Meeting < ActiveRecord::Base
  belongs_to :room
  
  validates_presence_of :room_id, :date
  
  scope :date_desc, -> { order("meetings.date desc") }
  scope :date_asc, -> { order("meetings.date asc") }
  
  before_update :update_events_created_at, if: :date_changed?
  after_destroy :destroy_events
  
  def destroy_events
    events.destroy_all
  end
  
  def events(pluck_member_ids = false)
    events = Event
    events = events.where("data @> 'meeting.id=>#{id}'")
    events = events.pluck(:member_id) if pluck_member_ids
    events
  end
  
  def update_events_created_at
    events.update_all created_at: date
  end
end
