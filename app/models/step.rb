class Step < ActiveRecord::Base
  belongs_to :sequence, touch: true
  belongs_to :task
  belongs_to :message
  has_many :tasks
  
  accepts_nested_attributes_for :task
  accepts_nested_attributes_for :message
end
