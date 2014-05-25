class Event < ActiveRecord::Base
  jibe
  
  serialize :json_data, JSON

  belongs_to :organization
  belongs_to :member
  
  validates_presence_of :member_id, :organization_id
  
  before_validation :parse_json
  before_save :save_flattened_data
  
  def parse_json
    if json_data[:member] && json_data[:member][:key]
      member = organization.members.where(key: json_data[:member][:key]).first
      
      if member
        self.member_id = member.user_id
        self.json_data[:member] = self.json_data[:member].merge(
          member.data.merge({
            id: member.id,
            name: member.name
          })
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
