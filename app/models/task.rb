class Task < ActiveRecord::Base
  belongs_to :folder
  belongs_to :creator, foreign_key: :creator_id, class_name: "User"
  
  validates_presence_of :creator, :content
  
  scope :by_ordinal, -> { order("tasks.ordinal asc") }
end
