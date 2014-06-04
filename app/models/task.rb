class Task < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  jibe

  belongs_to :folder, touch: true
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :contact, foreign_key: :contact_id, class_name: "Member"
  belongs_to :member
  
  validates_presence_of :creator, :content
  
  scope :by_ordinal, -> { order "tasks.ordinal asc" }
  scope :complete, -> { where complete: true }
  scope :incomplete, -> { where complete: false }
  scope :by_completed_at, -> { order "tasks.updated_at desc" }
  
  before_save :update_completed_at, if: :complete_changed?
  
  def update_completed_at
    self.completed_at = complete? ? Time.zone.now : nil
  end
  
  def story_data
    d = {}
    
    if contact
      mdata = {}
      mdata["name"] = contact.name
      mdata["member_name"] = mdata["name"]
      mdata["contact_name"] = mdata["name"]
      
      contact.data.each do |k, v|
        real_key = k.gsub(".", "_")
        mdata[real_key] = v
        mdata["member_#{real_key}"] = v
        mdata["contact_#{real_key}"] = v
      end
      
      d = d.merge(mdata)
    end
    
    d
  end
  
  def content_for_contact
    Mustache.render content.gsub("contact.", "contact_").gsub("member.", "member_"), story_data
  end
  
  def linked_content
    helpers = ActionController::Base.helpers
    d = {}
    
    story_data.each do |k, v|
      key = k.gsub(".", "_")

      if k =~ /member/ || k =~ /contact/
        content = helpers.link_to v, member_path(contact.organization, contact_id), remote: true
      elsif k =~ /message/
        content = helpers.link_to v, message_path(message.organization, story_data["message_id"]), remote: true
      else
        content = v
      end
      
      d[key] = content
    end
    
    story = Mustache.render content.gsub("contact.", "contact_").gsub("member.", "member_"), d
    CGI::unescapeHTML story
  end
  
  def jibe_data
    attributes.merge({
      complete_changed: complete_changed?,
      ordinal_changed: ordinal_changed?
    })
  end
end
