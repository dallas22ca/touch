class User < ActiveRecord::Base
  attr_accessor :ignore_password, :ignore_email, :invitation_token, :ignore_unique_email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable
  
  has_many :identities
  has_many :members
  has_many :organizations, through: :members
  
  has_attached_file :avatar,
    default_url: "/imgs/user_no_avatar.jpg"
  
  validates_attachment_content_type :avatar, content_type: /jpeg|jpg|gif|png/
  
  validates_presence_of   :email, if: :email_required?
  validates_uniqueness_of :email, allow_blank: true, if: -> { email_changed? && !ignore_unique_email }
  validates_format_of     :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?

  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: Devise.password_length, allow_blank: true
  
  accepts_nested_attributes_for :organizations, reject_if: Proc.new { |o| o["permalink"].blank? }
  
  before_save :format_website
  after_save :accept_invitation, if: :invitation_token
  
  def accept_invitation
    foldership = Foldership.where(token: invitation_token).first!
    org = foldership.folder.organization
    member = org.members.where(user_id: id).first_or_create!
    foldership.update! member: member
    foldership.accept
    update! invitation_token: nil
  end
  
  def format_website
    self.website = "http://#{website}" unless website.blank? || website =~ /http/
  end
  
  def self.from_omniauth(auth, domain)
    identity = Identity.where(auth.slice(:provider, :uid).merge({ domain: domain })).first_or_initialize
    
    unless identity.user
      identity.username = auth.info.nickname
      user = User.new
      user.ignore_email = true
      user.ignore_unique_email = true
      user.ignore_password = true
      user.email = auth.info.email
      user.name = auth.extra.raw_info.name
      
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
    if ignore_password
      false
    else
      if identities.any?
        false
      else
        super
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
  
  def save_with_domain(domain)
  end
end
