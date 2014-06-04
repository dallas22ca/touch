class Foldership < ActiveRecord::Base
  jibe
  
  serialize :roles, Array
  
  attr_accessor :resend

  belongs_to :folder
  belongs_to :member, dependent: :destroy
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  validates_presence_of :folder_id, :roles
  validates_presence_of :member_id, if: Proc.new { email.blank? || name.blank? }
  validates_presence_of :email, if: Proc.new { !member && new_record? }
  validates_presence_of :name, if: Proc.new { !member && new_record? }
  validates_uniqueness_of :member_id, scope: [:folder_id], message: "is already present", if: :member
  
  before_validation :set_roles, if: :preset_changed?
  before_create :link_to_member
  before_save :generate_token, if: Proc.new { token.blank? }
  after_create :send_email
  after_save :send_email, if: :resend
  
  scope :unaccepted, -> { where accepted: false }
  scope :accepted, -> { where accepted: true }
  
  def send_email
    FolderMailer.invitation(id).deliver unless member == folder.creator
  end
  
  def name_and_email
    "#{name} <#{email}>"
  end
  
  def accept
    member.roles.push "folders/read"
    member.roles.push "folders/write" if member.roles.include? "admin"
    update! accepted: true if member.save!
  end
  
  def link_to_member
    unless self.member
      org = folder.organization
      self.member = org.members.where("data -> 'email' = ?", email).first
    end
    
    if self.member
      self.name = member.name
      self.email = member.data["email"]
    end
  end
  
  def role_explained
    case preset
    when "admin"
      "Agent"
    when "read_only"
      "Client"
    when "documents_only"
      "Lawyer"
    end
  end
  
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64.gsub(/-|_/, "")
      break random_token unless Foldership.exists?(token: random_token)
    end
  end
  
  def name_or_member_name
    member ? member.name : name
  end
  
  def permits?(resource, action)
    return true if resource.is_a?(Object) && resource.try(:creator_id) == member_id
    resource = resource.class.name.downcase.pluralize unless resource.is_a?(Symbol) || resource.is_a?(String)
    action = action.to_sym unless action.is_a? Symbol
    permit = roles.include? "#{resource}/#{action}"
    logger.info "Attempting to gain permissions to #{resource}/#{action}... #{permit ? "\033[0;32msuccess\033[0m" : "\033[0;31mfail\033[0m"}"
    permit
  end
  
  def set_roles
    self.roles = Foldership.permissions.select { |p| p[Foldership.presets[preset.to_s.to_sym]] }
  end
  
  def self.presets
    {
      admin: /\//,
      read_only: /(\/read)|(comments\/write)/,
      documents_only: /documents|folderships\/read/
    }
  end
  
  def self.permissions
    [
      "folders/read",
      "folders/write",
      "folders/delete",
      "comments/read",
      "comments/write",
      "comments/delete",
      "folder_tasks/read",
      "folder_tasks/write",
      "folder_tasks/delete",
      "documents/read",
      "documents/write",
      "documents/delete",
      "homes/read",
      "homes/write",
      "homes/delete",
      "folderships/read",
      "folderships/write",
      "folderships/delete"
    ]
  end
end
