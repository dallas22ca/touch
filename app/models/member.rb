class Member < ActiveRecord::Base
  serialize :permissions, Array
  
  belongs_to :user
  belongs_to :organization
  
  has_many :events

  validates_uniqueness_of :key, scope: :organization
  
  before_validation :parameterize_key, if: :key_changed?
  
  before_create :set_initial_admin
  before_create :permissions
  
  after_create :set_user_data
  after_create :set_key, unless: :key
  
  scope :last_name_asc, -> { order("members.data->'last_name' desc") }
  
  def set_user_data
    split = user.name.split(" ")
    d = self.data
    d ||= {}
    d["first_name"] = split.first
    d["last_name"] = split.last == split.first ? "" : split.last
    d["email"] = user.email.to_s
    update_columns data: d
  end
  
  def name
    name = data["first_name"]
    name += " " + data["last_name"] unless data["last_name"].blank? 
  end
  
  def pretty_name
    pretty_name = ""
    pretty_name += "#{data["last_name"]}, " unless data["last_name"].blank?
    pretty_name += data["first_name"]
  end
  
  def parameterize_key
    self.key = key.parameterize
  end
  
  def set_key
    update key: id.to_s
  end
  
  def set_initial_admin
    self.permissions = ["admin"] if organization.members.empty?
  end
  
  def set_permissions
    self.permissions ||= ["member"]
  end
  
  def permits?(clearance)
    permissions.include?("admin") || permissions.include?(clearance)
  end
end
