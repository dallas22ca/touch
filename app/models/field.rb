class Field < ActiveRecord::Base
  belongs_to :organization
  
  before_validation :set_name_and_permalink
  
  validates_presence_of :organization_id, :permalink, :name
  validates_uniqueness_of :permalink, scope: :organization_id
  
  def set_name_and_permalink
    self.permalink = self.permalink.parameterize.underscore
    self.name = self.permalink.humanize.split(" ").map{ |w| w.capitalize }.join(" ")
  end
end
