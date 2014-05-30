class Message < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  
  serialize :member_ids, Array

  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :organization
  
  validates_presence_of :subject, :body
  validates_presence_of :member_ids
  
  after_create :prepare_for_delivery
  
  def prepare_for_delivery
    member_ids.each do |member_id|
      MessageWorker.perform_async id, "deliver", member_id: member_id
    end
  end
  
  def members
    organization.members.where(id: member_ids)
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
