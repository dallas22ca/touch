class Sequence < ActiveRecord::Base
  serialize :segment_ids, Array

  belongs_to :organization
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  has_many :steps
  has_many :tasks, through: :steps
  
  scope :manual, -> { where strategy: "manual" }
  
  before_validation :truncate_segment_ids, if: -> { strategy == "manual" }
  
  after_save :generate_tasks, if: -> { strategy == "recurring" || strategy == "annual" }
  after_touch :generate_tasks
  
  def truncate_segment_ids
    self.segment_ids = []
  end
  
  def generate_tasks(now = Time.zone.now, contact_ids = false)
    unless contact_ids
      for_all_contacts = true
      contact_ids = member_ids
    end

    case strategy
    when "recurring"
    when "annual", "manual"
      if for_all_contacts
        if contact_ids.empty?
          creator.tasks.destroy_all
        end
      end
      
      if strategy == "annual"
        first_due = Time.zone.parse(date.strftime("%B %-d #{now.year}"))
        due_dates = [first_due, first_due + 1.year]
      else
        due_dates = [now]
      end
      
      steps.find_each do |step|
        if for_all_contacts && contact_ids.any?
          creator.tasks.where("step_id = ? and contact_id not in (?)", step.id, contact_ids).destroy_all
        end
        
        contact_ids.each do |contact_id|
          due_dates.each do |due_date|
            task = creator.tasks.where(step: step, year: due_date.year, contact_id: contact_id).first_or_initialize
            task.assign_attributes content: step.task.content, contact_id: contact_id, due_at: due_date + step.offset.seconds, creator: creator
            task.message = step.task.message if step.task.message
            task.save
          end
        end
      end
    end
  end
  
  def remove_tasks_for(contact_ids = [])
    creator.tasks.where(contact_id: contact_ids).destroy_all
  end
  
  def segments
    organization.segments.where(id: segment_ids)
  end
  
  def member_ids
    if segment_ids.any?
      ids = []
      segments.map { |s| ids = ids + s.member_ids }
    else
      ids = organization.member_ids
    end
    
    ids.uniq
  end
end
