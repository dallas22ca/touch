class Folder < ActiveRecord::Base
  belongs_to :organization
  has_many :tasks, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :homes, dependent: :destroy
  
  belongs_to :creator, foreign_key: :creator_id, class_name: "User"
  
  validates_presence_of :name
end
