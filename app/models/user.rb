class User < ActiveRecord::Base
  attr_accessor :ignore_password, :ignore_email, :invitation_token

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :identities
  has_many :members
  has_many :organizations, through: :members
  
  has_attached_file :avatar,
    default_url: "/imgs/user_no_avatar.jpg"
  
  validates_attachment_content_type :avatar, content_type: /jpeg|jpg|gif|png/
  
  accepts_nested_attributes_for :organizations, reject_if: Proc.new { |o| o["permalink"].blank? }
  
  validates_presence_of :name
  
  before_save :format_website
  after_save :add_to_folder, if: :invitation_token
  after_save :remove_invitation_token, if: :invitation_token
  
  def remove_invitation_token
    self.invitation_token = nil
  end
  
  def add_to_folder
    foldership = Foldership.where(token: invitation_token).first!
    org = foldership.folder.organization
    member = org.members.where(user_id: id).first_or_create!
    foldership.update! member: member
    foldership.accept
  end
  
  def format_website
    self.website = "http://#{website}" unless website.blank? || website =~ /http/
  end
  
  def self.from_omniauth(auth)
    identity = Identity.where(auth.slice(:provider, :uid)).first_or_initialize
    
    unless identity.user
      identity.username = auth.info.nickname
      user = User.new
      
      if auth.info.email.blank?
        user.ignore_email = true
      else
        user.email = auth.info.email
      end
      
      user.name = auth.extra.raw_info.name
      user.ignore_password = true
      
      unless auth.info.image.blank?
        uri = URI.parse(auth.info.image)
        uri.scheme = 'https'
        user.avatar = URI.parse("#{auth.info.image.gsub("http", "https")}?type=large")
      end
      
      user.save!
      identity.user = user
      identity.save!
    end
    
    identity.user
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    if ignore_password || identities.empty?
      false
    else
      if encrypted_password.blank?
        super
      else
        false
      end
    end
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
  
  def email_required?
    if ignore_email
      false
    else
      super
    end
  end
end
