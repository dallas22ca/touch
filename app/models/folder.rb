class Folder < ActiveRecord::Base
  attr_accessor :seed

  belongs_to :organization
  has_many :tasks, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :homes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :folderships, dependent: :destroy
  has_many :members, through: :folderships
  has_many :users, through: :members
  
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  validates_presence_of :name

  after_create :create_foldership, if: Proc.new { folderships.empty? }
  after_create :seed_tasks, unless: Proc.new { seed.blank? }
  
  def create_foldership
    folderships.create!(
      member: creator, 
      role: "admin",
      accepted: true
    )
  end
  
  def seed_tasks
    if seed == "buyer" || seed == "seller"
      seed_folder = Folder.sample_seller
    else
      seed_folder = organization.folders.find seed
    end
    
    if seed_folder
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
    end
    
    # delete users of folder
  end
  
  def self.sample_seller
    f = Folder.new
    [
      "Complete all paperwork", 
      "Install lockbox", 
      "Install sign and directionals", 
      "Take pictures", 
      "Get copy of existing title insurance, survey and deed", 
      "Enter into MLS as Provisional", 
      "Upload media into MLS and make listing Active", 
      "Order Home Warranty on-line if Seller coverage is applicable", 
      "Order listing binder (preliminary title) & send copy of existing title for credit at closing", 
      "Input into EProperty site www.epropertysites.com for stand-alone website, if applicable", 
      "Order sign rider to advertise website",
      "Check Realtor.com, local mls and company website to make certain pictures loaded into public sites correctly", 
      "Scan Listing Check List plus all associated forms and email to office", 
      "Enter into your database manager", 
      "Send email to agents via reverse prospecting in MLS", 
      "Prepare inside brochures and outside flyers", 
      "Prepare homebook", 
      "Return originals of title, deed and survey to Seller and deliver brochures and flyers", 
      "Add to Craig's List, Postlets, and other free classified sites", 
      "Verify all websites (Trulia, Yahoo, Zillow, Realtor.com) to make certain listing is appears correctly", 
      "Send Seller links to all websites to show marketing plan",
      "Send emails to other agents to announce new listing", 
      "Send out Just Listed postcards or flyers", 
      "Contact Seller and give status update", 
      "Review preliminary title for any issues",
      "Schedule an open house",
      "Schedule an agent's open house", 
      "Seller update with website stat reports"
    ].map { |c| f.tasks.new content: c }
    f
  end
end
