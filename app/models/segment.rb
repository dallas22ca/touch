class Segment < ActiveRecord::Base
  serialize :filters, JSON
  belongs_to :organization
  
  validates_presence_of :organization_id, :name
  
  def members
    organization.filter_members symbolized_filters
  end
  
  def symbolized_filters
    filters.map { |f| f.symbolize_keys }
  end
end
