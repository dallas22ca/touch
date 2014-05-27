class Task < ActiveRecord::Base
  jibe

  belongs_to :folder, touch: true
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  validates_presence_of :creator, :content
  
  scope :by_ordinal, -> { order "tasks.ordinal asc" }
  scope :complete, -> { where complete: true }
  scope :incomplete, -> { where complete: false }
  scope :by_completed_at, -> { order "tasks.updated_at desc" }
  
  def jibe_data
    attributes.merge({
      complete_changed: complete_changed?,
      ordinal_changed: ordinal_changed?
    })
  end
end
