class Task < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  jibe

  belongs_to :folder, touch: true
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :contact, foreign_key: :contact_id, class_name: "Member"
  belongs_to :member
  belongs_to :step
  belongs_to :message
  
  validates_presence_of :content
  validates_presence_of :creator, unless: :template?
  
  scope :by_ordinal, -> { order "tasks.ordinal asc" }
  scope :complete, -> { where complete: true }
  scope :incomplete, -> { where complete: false }
  scope :by_completed_at, -> { order "tasks.updated_at desc" }
  scope :not_a_template, -> { where template: false }
  scope :template, -> { where template: true }
  scope :has_message, -> { where("message_id is not ?", nil) }
  
  accepts_nested_attributes_for :message, reject_if: Proc.new { |m| m["body"].blank? }
  
  before_validation :create_task_content, if: :message
  after_create :do_deliver_message, if: -> { !template? && !complete? && message && message_overdue? }
  
  before_save :update_completed_at, if: :complete_changed?
  before_save :do_skip_jibe, if: :template?
  
  def message_overdue?
    due_at.in_time_zone <= Time.zone.now.end_of_day
  end
  
  def do_deliver_message
    message.deliver_to [contact_id], id
  end
  
  def create_task_content
    self.content = "Send {{ message.subject }} to {{ contact.name }} (automatic)."
  end
  
  def do_skip_jibe
    self.skip_jibe = true
  end
  
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
    
    if message
      d["message_subject"] = message.subject
      d["message_id"] = message.id
    end
    
    d
  end
  
  def content_for_contact
    Mustache.render content.gsub("contact.", "contact_").gsub("member.", "member_").gsub("message.", "message_"), story_data
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
    
    story = Mustache.render content.gsub("contact.", "contact_").gsub("member.", "member_").gsub("message.", "message_"), d
    CGI::unescapeHTML story
  end
  
  def jibe_data
    attributes.merge({
      complete_changed: complete_changed?,
      ordinal_changed: ordinal_changed?
    })
  end
end
