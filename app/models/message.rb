class Message < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  serialize :member_ids, Array
  serialize :segment_ids, Array

  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :organization
  
  before_validation :remove_blank_segment_ids, if: :segment_ids
  validates_presence_of :subject, :body
  validate :validate_recipients, if: -> { member_ids.empty? && segment_ids.empty? }
  
  after_create :prepare_for_delivery
  
  def remove_blank_segment_ids
    self.segment_ids = segment_ids.reject(&:blank?).map(&:to_i)
  end
  
  def validate_recipients
    errors.add :recipients, "are required"
  end
  
  def prepare_for_delivery
    ids = []
    member_ids.map { |id| ids.push id }
    
    if segment_ids.any?
      if segment_ids.include? 0
        organization.members.map { |m| ids.push m.id }
      else
        segments.each do |segment|
          segment.members.each do |member|
            ids.push member.id
          end
        end
      end
    end
    
    ids.uniq.each do |member_id|
      MessageWorker.perform_async id, "deliver", member_id: member_id
    end
  end
  
  def members
    organization.members.where(id: member_ids)
  end
  
  def segments
    organization.segments.where(id: segment_ids.reject { |a| a == 0 })
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
  
  def linked_body_for(member, output = "content")
    content = Message.content_for(body, member)
    links = URI::extract(content, ["http", "ftp", "https", "mailto"])

    links.each_with_index do |href, index|
      url = click_url(organization, id * CONFIG["secret_number"], member.id * CONFIG["secret_number"], index, href: CGI::escape(href))
      content = content.sub(href, "<a href=\"#{url}\">#{href}</a>")
    end
    
    output == "count" ? links.count : content
  end
end
