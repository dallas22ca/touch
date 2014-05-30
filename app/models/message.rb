class Message < ActiveRecord::Base
  serialize :member_ids, Array

  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  belongs_to :organization
  
  after_create :prepare_for_delivery
  
  def prepare_for_delivery
    member_ids.each do |member_id|
      MessageWorker.perform_async id, "deliver", member_id: member_id
    end
  end
  
  def members
    organization.members.where(id: member_ids)
  end
end
