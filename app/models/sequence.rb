class Sequence < ActiveRecord::Base
  serialize :segment_ids, Array

  belongs_to :organization
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  has_many :steps
  has_many :tasks, through: :steps
  
  scope :manual, -> { where strategy: "manual" }
  
  before_validation :truncate_segment_ids, if: -> { strategy == "manual" }
  
  after_save :generate_tasks, if: -> { strategy != "manual" }
  after_touch :generate_tasks, if: -> { strategy != "manual" }
  
  def truncate_segment_ids
    self.segment_ids = []
  end
  
  def generate_tasks(now = Time.zone.now, contact_ids = false)
    if !contact_ids
      contact_ids = member_ids
      creator.tasks.where(step_id: step_ids).destroy_all if contact_ids.empty?
      creator.tasks.where(step_id: step_ids).where("contact_id not in (?)", contact_ids).destroy_all if contact_ids.any?
    end

    case strategy
    when "recurring"
      occurances_within_time_period = (time_period / interval).floor
      occurances_within_time_period.times do |n|
        start = now + (interval * n)
        finish = now + (interval * (n + 1))
        random_date = rand(start..finish)
        
        contact_ids.each do |contact_id|
          last_task = false
          
          steps.each do |step|
            task = creator.tasks.where(due_at: start..finish, contact_id: contact_id).first
            task = creator.tasks.new(contact_id: contact_id) unless task
            due_at = last_task ? last_task.due_at + interval : random_date
            task.assign_attributes content: step.task.content, due_at: due_at + step.offset.seconds, creator: creator
            task.message = step.task.message if step.task.message
            task.save!
            last_task = task
          end
        end
      end
      
    when "annual", "manual"
      
      if strategy == "annual"
        first_due = Time.zone.parse(date.strftime("%B %-d #{now.year}"))
        due_dates = [creator.next_available_day_for(first_due), creator.next_available_day_for(first_due + 1.year)]
      else
        due_dates = [creator.next_available_day_for(now)]
      end
      
      steps.find_each do |step|
        contact_ids.each do |contact_id|
          due_dates.each do |due_date|
            task = creator.tasks.where(step: step, year: due_date.year, contact_id: contact_id, creator: creator).first_or_initialize
            task.assign_attributes content: step.task.content, due_at: due_date + step.offset.seconds
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
  
  def time_period
    1.year
  end
end
