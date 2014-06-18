class Bitly < ActiveRecord::Base
  before_validation :generate_token
  validates_presence_of :href, :token
  
  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(2).gsub(/-|_/, "")
      break random_token unless Bitly.exists?(token: random_token)
    end
  end
  
  def url
    "https://tbnow.co/#{token}"
  end
end
