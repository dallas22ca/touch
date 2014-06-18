class Event < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  jibe
  
  serialize :json_data, JSON

  belongs_to :organization
  belongs_to :member
  
  validates_presence_of :member_id, :organization_id
  
  before_validation :parse_json
  before_save :save_flattened_data
  
  scope :delivered, -> { where verb: "was sent" }
  scope :clicked, -> { where verb: "clicked" }
  scope :opened, -> { where verb: "opened" }
  scope :replied, -> { where verb: "replied to" }
  
  def parse_json
    if json_data[:member] && json_data[:member][:key]
      member = organization.members.where(key: json_data[:member][:key]).first
      
      if member
        self.member_id = member.id
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
  
  def linked_story
    helpers = ActionController::Base.helpers
    d = {}
    
    data.each do |k, v|
      key = k.gsub(".", "_")

      if k =~ /member/ || k =~ /contact/
        content = helpers.link_to v, member_path(organization, member_id), remote: true
      elsif k =~ /message/
        content = helpers.link_to v, message_path(organization, data["message.id"]), remote: true
      else
        content = v
      end
      
      d[key] = content
    end
    
    story = Mustache.render description.gsub(".", "_"), d
    CGI::unescapeHTML story
  end
  
  def self.for_mobile(mobile)
    where("'#{mobile.gsub("+1", "")}' ~ regexp_replace(data -> 'member.mobile', '[^0-9]', '', 'g')")
  end
end
