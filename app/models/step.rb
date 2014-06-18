class Step < ActiveRecord::Base
  belongs_to :sequence
  belongs_to :task
  belongs_to :message
  has_many :tasks
  
  accepts_nested_attributes_for :task, reject_if: proc { |t| t["message_attributes"].blank? && t["content"].blank? }
end
