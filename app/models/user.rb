class User < ActiveRecord::Base
  attr_accessor :ignore_password, :ignore_email, :invitation_token

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :members
  has_many :organizations, through: :members
  
  has_attached_file :avatar,
    default_url: "/imgs/user_no_avatar.jpg"
  
  validates_attachment_content_type :avatar, content_type: /jpeg|jpg|gif|png/
  
  accepts_nested_attributes_for :organizations, reject_if: Proc.new { |o| o["permalink"].blank? }
  
  validates_presence_of :name
  
  before_save :format_website
  after_save :add_to_folder, if: :invitation_token
  
  def add_to_folder
    foldership = Foldership.where(token: invitation_token).first
    member = foldership.member.update! user: self
    foldership.accept
  end
  
  def format_website
    self.website = "http://#{website}" unless website.blank? || website =~ /http/
  end
  
  def password_required?
    if ignore_password
      false
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
