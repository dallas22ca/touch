class Home < ActiveRecord::Base
  serialize :data, JSON

  belongs_to :folder
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
end
