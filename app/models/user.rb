class User < ActiveRecord::Base
  attr_accessor :ignore_password, :ignore_email

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
