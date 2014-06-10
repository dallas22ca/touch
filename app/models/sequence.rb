class Sequence < ActiveRecord::Base
  serialize :segment_ids, Array

  belongs_to :organization
  belongs_to :creator, foreign_key: :creator_id, class_name: "Member"
  has_many :steps
  has_many :tasks, through: :steps
  
  scope :manual, -> { where strategy: "manual" }
  
  accepts_nested_attributes_for :steps
  
  before_validation :truncate_segment_ids, if: -> { strategy == "manual" }
  
  after_save :generate_tasks, if: -> { strategy != "manual" }
  after_touch :generate_tasks, if: -> { strategy != "manual" }
  after_destroy :destroy_related_tasks
  
  def destroy_related_tasks
    Task.where(step_id: step_ids).destroy_all
    Step.where(id: step_ids).destroy_all
  end
  
  def truncate_segment_ids
    self.segment_ids = []
  end
  
  def generate_tasks(now = Time.zone.now, contact_ids = false)
    if !contact_ids
      contact_ids = member_ids
      creator.tasks.where(step_id: step_ids).incomplete.destroy_all if contact_ids.empty?
      creator.tasks.where(step_id: step_ids).where("contact_id not in (?)", contact_ids).incomplete.destroy_all if contact_ids.any?
    end
    
    contacts = organization.members.find(contact_ids)

    case strategy
    when "recurring"
      occurances_within_time_period = (time_period / interval).floor
      creator.tasks.where(step_id: step_ids).incomplete.destroy_all if interval_changed?

      contacts.each do |contact|
        start = now
        finish = now + interval
        base_date = rand(start..finish)
        
        occurances_within_time_period.times do |n|
          steps.each do |step|
            due_at = base_date + (interval * n) + step.offset.seconds
            due_at = creator.next_available_day_for(due_at)
          
            if due_at >= Time.zone.now
              task = creator.tasks.where(step: step, due_at: start..finish, contact_id: contact.id).first
              
              if !task
                task = creator.tasks.new(step: step, contact_id: contact.id)
                task.assign_attributes content: step.task.content, due_at: due_at, creator: creator
                task.message = step.task.message if step.task.message
                task.save!
              end
            end
          end
          
          start += interval
          finish += interval
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
        contacts.each do |contact|
          due_dates.each do |due_date|
            task = creator.tasks.where(step: step, year: due_date.year, contact_id: contact.id, creator: creator).first_or_initialize
            task.assign_attributes content: step.task.content, due_at: due_date + step.offset.seconds
            task.message = step.task.message if step.task.message
            task.save
          end
        end
      end
      
    end
  end
  
  def remove_tasks_for(contact_ids = [])
    creator.tasks.where(contact_id: contact_ids).incomplete.destroy_all
  end
  
  def add_tasks_for(contact_ids = [])
    generate_tasks Time.zone.now, contact_ids
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
  
  def name
    case strategy
    when "annual"
      "Annual followup on #{date.strftime("%B %-d")}"
    when "recurring"
      "Every #{(offset / 60 / 60 / 24).days} days"
    when "manual"
      if steps.first.task.message
        "#{steps.first.task.message.subject}"
      else
        "#{steps.first.task.content}"
      end
    end
  end
end
