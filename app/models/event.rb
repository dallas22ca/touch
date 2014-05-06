class Event < ActiveRecord::Base
  serialize :json_data, JSON

  belongs_to :organization
  belongs_to :member
  
  validates_presence_of :member_id, :organization_id
  
  before_create :parse_json
  
  def parse_json
    self.member = organization.members.where(key: json_data[:contact][:key]).first
  end
end
