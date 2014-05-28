class Identity < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id, :provider, :domain
end
