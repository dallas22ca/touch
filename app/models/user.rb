class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :memberships
  has_many :organizations, through: :memberships
  
  accepts_nested_attributes_for :organizations
  
  validates_presence_of :name
  
  def first_name
    name.split(" ").first
  end
  
  def last_name
    name.split(" ").last
  end
end
