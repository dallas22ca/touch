class Comment < ActiveRecord::Base
  jibe

  belongs_to :folder
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  validates_presence_of :creator, :body
end
