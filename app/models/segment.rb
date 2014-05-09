class Segment < ActiveRecord::Base
  serialize :filters, JSON
  belongs_to :organization
  
  validates_presence_of :organization_id, :name
end
