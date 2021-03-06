class Message < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  serialize :member_ids, Array
  serialize :segment_ids, Array

  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :organization
  has_many :tasks
  
  has_attached_file :attachment,
    url: "//s3.amazonaws.com/#{CONFIG["aws_bucket"]}/message/attachments/:hash/:style/:filename",
    path: "/message/attachments/:hash/:style/:filename",
    hash_secret: CONFIG["secret_key_base"]

  validates_attachment_content_type :attachment, content_type: /(image|application|doc|xls|csv|txt|text|html|plain)/
  
  scope :not_a_template, -> { where template: false }
  scope :template, -> { where template: true }
  
  before_validation :set_via_default
  before_validation :set_organization, unless: :organization_id
  before_validation :remove_blank_segment_ids, if: :segment_ids
  validates_presence_of :body, :creator_id, :via
  validates_presence_of :subject, unless: -> { via == "sms" }
  validate :validate_recipients, if: -> { !template? && member_ids.empty? && segment_ids.empty? }
  
  after_commit :prepare_for_delivery, if: -> { !template? }, on: :create
  
  def set_via_default
    self.via ||= "email"
    self.subject = self.body.truncate(25).strip if via == "sms" && subject.blank?
  end
  
  def set_organization
    self.organization = creator.organization
  end
  
  def remove_blank_segment_ids
    self.segment_ids = segment_ids.reject(&:blank?).map(&:to_i)
  end
  
  def validate_recipients
    errors.add :recipients, "are required"
  end
  
  def prepare_for_delivery
    ids = []
    
    organization.members.find(member_ids).each do |member|
      if (via == "email" && member.emailable?) || (via == "sms" && member.smsable?)
        MessageWorker.perform_async id, "deliver", member_id: member.id, via: via
      end
    end
    
    if segment_ids.any?
      if segment_ids.include? 0
        organization.members.each do |member|
          if (via == "email" && member.emailable?) || (via == "sms" && member.smsable?)
            ids.push member.id
          end
        end
      else
        segments.each do |segment|
          segment.members.each do |member|
            if (via == "email" && member.emailable?) || (via == "sms" && member.smsable?)
              ids.push member.id
            end
          end
        end
      end
    end
    
    ids.uniq.each do |member_id|
      MessageWorker.perform_async id, "deliver", member_id: member_id, via: via
    end
  end
  
  def deliver_to(member_ids = [], task_id = false)
    organization.members.find(member_ids).each do |member|
      if (via == "email" && member.emailable?) || (via == "sms" && member.smsable?)
        MessageWorker.perform_async id, "deliver", member_id: member.id, task_id: task_id, via: via
      end
    end
  end
  
  def members
    organization.members.where(id: member_ids)
  end
  
  def segments
    organization.segments.where(id: segment_ids.reject { |a| a == 0 })
  end
  
  def events
    organization.events.where("data @> 'message.id=>#{id}'")
  end
  
  def opens
    events.opened
  end
  
  def clicks
    events.clicked
  end
  
  def deliveries
    events.delivered
  end
  
  def replies
    events.replied
  end
  
  def self.content_for(content, member)
    member_data = member.data.merge({
      name: member.name,
      pretty_name: member.pretty_name
    })
    
    d = {
      contact: member_data,
      member: member_data
    }
    
    Mustache.render content.to_s.gsub(/\n/, "<br>"), d
  end
  
  def linked_body_for(member, output = "email")
    content = Message.content_for body, member
    content += " #{attachment.url}" if attachment.exists? && via == "sms"
    links = URI::extract(content, ["http", "ftp", "https", "mailto"])

    links.each_with_index do |href, index|
      click_url = click_url(organization, id * CONFIG["secret_number"], member.id * CONFIG["secret_number"], index, href: CGI::escape(href))
      url = Bitly.create(href: click_url).url
      
      case output
      when "email"
        content = content.sub(href, "<a href=\"#{url}\">#{href}</a>")
      when "sms"
        content = content.sub(href, url)
      end
    end
    
    output == "count" ? links.count : content
  end
  
  def self.deliver_overdue(now = Time.zone.now)
    Task.where("due_at < ?", now).has_message.not_a_template.find_each do |task|
      if task.creator.organization.events.where("verb = 'was sent' and data @> 'message.id=>#{task.message_id}' and data @> 'member.id=>#{task.contact_id}'").empty?
        task.do_deliver_message
      end
    end
  end
  
  def self.create_event_for(message_id, member_id, task_id, verb)
    message = Message.find(message_id)
    member = message.organization.members.find(member_id)
    task = message.creator.tasks.find(task_id) unless "#{task_id}".blank?
    description = "{{ member.name }} #{verb} {{ message.subject }}"
    
    unless message.to.blank?
      description = "{{ message.subject }} was sent to #{message.to}"
      verb = "was sent to"
    end
    
    event = message.organization.events.new(
      description: description,
      verb: verb,
      json_data: {
        message: message.attributes,
        member: {
          key: member.key
        }
      }
    )
    
    if task
      task.update complete: true
      event.json_data[:task] = task.attributes
    end

    event.save
  end
  
  def self.create_delivery_for(message_id, member_id, task_id)
    Message.create_event_for message_id, member_id, task_id, "was sent"
  end
  
  def self.create_reply_for(message_id, member_id, task_id)
    Message.create_event_for message_id, member_id, task_id, "replied to"
  end
  
  def self.send_as_sms(message_id, member_id, task_id)
    message = Message.find(message_id)
    member = message.organization.members.find(member_id)
    client = Twilio::REST::Client.new CONFIG["twilio_account_sid"], CONFIG["twilio_auth_token"]
    
    if !Rails.env.production? || client.account.messages.create(
      from: Message.phone_numbers[message.organization_id % Message.phone_numbers.size],
      to: Member.prepare_phone(member.data["mobile"]),
      body: message.linked_body_for(member, "sms")
    )
      Message.create_delivery_for message_id, member_id, task_id
    end
  end
  
  def self.phone_numbers
    ["+16474966225"]
  end
end
