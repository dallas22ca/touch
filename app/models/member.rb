class Member < ActiveRecord::Base
  jibe
  
  attr_accessor :bulk_action

  serialize :roles, Array
  
  belongs_to :user
  belongs_to :organization, counter_cache: true, touch: true
  
  has_many :events, dependent: :destroy
  has_many :folderships, dependent: :destroy
  has_many :folders, through: :folderships
  has_many :tasks

  validates_uniqueness_of :key, scope: :organization
  
  before_validation :set_key, unless: :key
  before_validation :parameterize_key, if: :key_changed?
  before_validation :intercept_full_name, if: -> { data.has_key? "full_name" }
  before_validation :flatten_roles, if: :roles_changed?
  before_validation :set_user_data, if: -> { user && user_id_changed? }

  before_create :set_initial_admin, if: Proc.new { organization.reload.members_count == 0 }
  before_create :set_member_role
  
  before_save :parameterize_data
  
  after_create :seed_data, if: Proc.new { roles.include?("admin") && organization.modules.include?("folders") }
  after_save :update_organization_fields
  
  scope :last_name_asc, -> { order("members.data->'last_name' asc") }
  scope :last_name_desc, -> { order("members.data->'last_name' desc") }
  scope :accepted, -> { where "folderships.accepted = ?", true }
  
  def parameterize_data
    self.data ||= {}
    d = {}
    self.data.map { |k, v| d[k.parameterize.underscore] = v }
    self.data = self.data.merge(d)
  end
  
  def update_organization_fields
    self.data ||= {}
    self.data.each do |k, v|
      organization.fields.where(permalink: k).first_or_create
    end
  end
  
  def intercept_full_name
    self.data ||= {}
    d = {}
    self.data["full_name"] = self.data[:full_name] if self.data.has_key? :full_name
    full_name = self.data["full_name"]
    split = full_name.split(" ")
    
    if split.length == 1
      d["first_name"] = split.first
      d["last_name"] = ""
    elsif split.length == 2
      d["first_name"] = split.first
      d["last_name"] = split.last
    else
      d["first_name"] = split.first
      
      if d["first_name"] =~ /\./
        d["salutation"] = split[0]
        d["first_name"] = split[1]
        d["last_name"] = full_name.split(d["first_name"]).last.strip
      else
        d["last_name"] = full_name.gsub(d["first_name"], "").strip
      end
    end
    
    self.data = self.data.merge(d)
  end
  
  def flatten_roles
    self.roles = self.roles.flatten
  end
  
  def set_user_data
    self.data ||= {}
    d = {}
    
    split = user.name.split(" ")
    d["first_name"] = split.first
    d["last_name"] = split.last == split.first ? "" : split.last
    d["email"] = user.email.to_s
    
    self.data = self.data.merge(d)
  end
  
  def name
    name = data["first_name"]
    name += " " + data["last_name"] unless data["last_name"].blank? 
    name
  end
  
  def pretty_name
    pretty_name = ""
    pretty_name += "#{data["last_name"]}, " unless data["last_name"].blank?
    pretty_name += data["first_name"] unless data["first_name"].blank?
  end
  
  def parameterize_key
    self.key = key.parameterize
  end
  
  def set_key
    self.key = loop do
      random_key = SecureRandom.urlsafe_base64.gsub(/-|_/, "")
      break random_key unless Member.exists?(organization_id: organization_id, key: random_key)
    end
  end
  
  def name_and_email
    "#{name} <#{data["email"]}>"
  end
  
  def set_member_role
    self.roles.push "member"
  end
  
  def add_preset(preset)
    if Member.presets.has_key? preset.downcase.to_sym
      new_roles = Member.permissions.select { |p| p[Member.presets[preset.to_sym]] }
      self.roles = (self.roles + new_roles).uniq
    end
  end
  
  def remove_preset(preset)
    if Member.presets.has_key? preset.downcase.to_sym
      new_roles = Member.permissions.select { |p| p[Member.presets[preset.to_sym]] }
      self.roles = (self.roles - new_roles).uniq
    end
  end
  
  def set_initial_admin
    self.roles.push "admin"
    
    organization.modules.each do |m|
      add_preset m.to_sym
    end
  end
  
  def seed_data
    organization.seed_first_folder
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
      attendance: /(rooms\/)|(members\/(write|delete))/,
      messages: /messages\//,
      tasks: /^tasks\//
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
      "rooms/delete",
      "messages/read",
      "messages/write",
      "messages/delete",
      "tasks/read",
      "tasks/write",
      "tasks/delete"
    ]
  end
  
  def jibe_data
    attributes.merge({
      name: name,
      pretty_name: pretty_name,
      bulk_action: !bulk_action.blank?
    })
  end
  
  def emailable?
    subscribed? && !data["email"].blank?
  end
  
  def toggle_subscribe
    update subscribed: !subscribed?
  end
end
