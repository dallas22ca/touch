class Foldership < ActiveRecord::Base
  attr_accessor :resend

  belongs_to :folder
  belongs_to :member
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  
  validates_presence_of :folder_id, :member_id, :role
  validates_presence_of :email, if: Proc.new { !member && new_record? }
  validates_presence_of :name, if: Proc.new { !member && new_record? }
  validates_uniqueness_of :member_id, scope: [:folder_id], message: "is already present", if: :member
  
  before_validation :link_to_member
  before_save :generate_token, if: Proc.new { token.blank? }
  after_create :send_email
  after_save :send_email, if: :resend
  
  scope :unaccepted, -> { where accepted: false }
  scope :accepted, -> { where accepted: true }
  
  def send_email
    FolderMailer.invitation(id).deliver unless member == folder.creator
  end
  
  def accept
    update accepted: true
  end
  
  def link_to_member
    unless self.member
      org = folder.organization
      self.member = org.members.where("data -> 'email' = ?", email).first
      
      unless self.member
        self.member = org.members.create! user: User.new(name: name, email: email), permissions: ["user"]
      end
    end
    
    if self.member
      self.name = self.member.name
      self.email = self.member.data["email"]
    end
  end
  
  def role_explained
    case role
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
    resource = resource.class.name.downcase.pluralize unless resource.is_a? Symbol
    action = action.to_sym unless action.is_a? Symbol
    r = Foldership.permissions[role.to_sym]
    r.has_key?(resource) && r[resource][action] == true
  end
  
  def self.permissions
    {
      admin: {
        folders: {
          read: true,
          write: true,
          delete: true
        },
        documents: {
          read: true,
          write: true,
          delete: true
        },
        tasks: {
          read: true,
          write: true,
          delete: true
        },
        homes: {
          read: true,
          write: true,
          delete: true
        },
        folderships: {
          read: true,
          write: true,
          delete: true
        }
      },
      read_only: {
        folders: {},
        documents: {
          read: true
        },
        tasks: {
          read: true
        },
        folderships: {
          read: true
        }
      },
      documents_only: {
        folders: {},
        documents: {
          read: true,
          write: true
        },
        tasks: {},
        folderships: {
          read: true
        }
      }
    }
  end
end
