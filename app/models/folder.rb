class Folder < ActiveRecord::Base
  attr_accessor :seed

  belongs_to :organization
  has_many :tasks, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :homes, dependent: :destroy
  
  belongs_to :creator, foreign_key: :creator_id, class_name: "User"
  
  validates_presence_of :name
  
  after_create :seed_tasks, unless: Proc.new { seed.blank? }
  
  def seed_tasks
    if seed == "buyer" || seed == "seller"
      org = Organization.where(permalink: "dallas").first
      seed_id = 1 if seed == "buyer"
      seed_id = 2 if seed == "seller"
      seed_folder = org.folders.find seed_id
    else
      seed_folder = organization.folders.find seed
    end
    
    seed_folder.tasks.each do |task|
      t = task.dup
      t.creator = self.creator
      t.complete = false
      self.tasks.push t
    end
    
    seed_folder.documents.each do |document|
      d = self.documents.new
      d.creator = self.creator
      d.file = document.file
      d.save
    end
    
    # delete users of folder
  end
end
