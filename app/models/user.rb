class User < ActiveRecord::Base
  attr_accessor :ignore_password, :ignore_email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :memberships
  has_many :organizations, through: :memberships
  
  accepts_nested_attributes_for :organizations
  
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
