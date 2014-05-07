class Event < ActiveRecord::Base
  serialize :json_data, JSON

  belongs_to :organization
  belongs_to :member
  
  validates_presence_of :member_id, :organization_id
  
  before_validation :parse_json
  before_save :save_flattened_data
  
  def parse_json
    if json_data[:contact] && json_data[:contact][:key]
      membership = organization.memberships.where(key: json_data[:contact][:key]).first
      
      if membership
        self.member_id = membership.user_id
        self.json_data[:contact] = self.json_data[:contact].merge(
          membership.data.merge(id: membership.id)
        )
      end
    end
  end
  
  def save_flattened_data
    self.data = Event.flatten_hash(json_data)
  end
  
  def self.flatten_hash(hash, parent = [], output = {})
    hash.flat_map do |key, value|
      case value
      when Hash
        Event.flatten_hash value, parent + [key], output
      else
        output[(parent + [key]).join(".")] = value
      end
    end
    
    output
  end
  
  def story
    d = {}
    data.map { |k, v| d[k.gsub(".", "_")] = v }
    Mustache.render description.gsub(".", "_"), d
  end
end
