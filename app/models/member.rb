class Member < ActiveRecord::Base
  serialize :roles, Array
  
  belongs_to :user
  belongs_to :organization, counter_cache: true
  
  has_many :events, dependent: :destroy
  has_many :folderships, dependent: :destroy
  has_many :folders, through: :folderships

  validates_uniqueness_of :key, scope: :organization
  
  before_validation :parameterize_key, if: :key_changed?

  before_create :set_initial_admin, if: Proc.new { organization.reload.members_count == 0 }
  before_create :set_roles

  after_create :set_user_data, if: :user
  after_create :set_key, unless: :key
  
  before_save :flatten_roles, if: :roles_changed?
  after_save :set_user_data, if: :user_id_changed?
  
  scope :last_name_asc, -> { order("members.data->'last_name' desc") }
  scope :accepted, -> { where "folderships.accepted = ?", true }
  
  def flatten_roles
    self.roles = self.roles.flatten
  end
  
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
    name
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
  
  def name_and_email
    "#{name} <#{data["email"]}>"
  end
  
  def set_roles
    self.roles.push "member"
  end
  
  def add_preset(preset)
    new_roles = Member.permissions.select { |p| p[Member.presets[preset.to_sym]] }
    self.roles = (self.roles + new_roles).uniq
  end
  
  def remove_preset(preset)
    new_roles = Member.permissions.select { |p| p[Member.presets[preset.to_sym]] }
    self.roles = (self.roles - new_roles).uniq
  end
  
  def set_initial_admin
    self.roles.push "admin"
    organization.modules.map { |m| add_preset m.to_sym }
  end
  
  def permits?(resource, action)
    return true if resource.is_a?(Object) && resource.try(:creator_id) == id
    resource = resource.class.name.downcase.pluralize unless resource.is_a?(Symbol) || resource.is_a?(String)
    action = action.to_sym unless action.is_a? Symbol
    permit = roles.include? "#{resource}/#{action}"
    logger.info "Attempting to gain permissions to #{resource}/#{action}... #{permit ? "\033[0;32msuccess\033[0m" : "\033[0;31mfail\033[0m"}"
    permit
  end
  
  def self.presets
    {
      admin: /\//,
      members: /members\//,
      contacts: /members\//,
      folders: /folders\//,
      attendance: /(rooms\/)|(members\/(write|delete))/
    }
  end
  
  def self.permissions
    [
      "admin",
      "member",
      "members/read",
      "members/write",
      "members/delete",
      "folders/read",
      "folders/write",
      "folders/delete",
      "rooms/read",
      "rooms/write",
      "rooms/delete"
    ]
  end
end
