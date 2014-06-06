require "spec_helper"

describe "Sequence", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["members", "messages"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
    @member.update_columns availability: [0, 1, 2, 3, 4, 5, 6]
  end
  
  # WHEN TO CREATE TASKS
  it "should add tasks when sequence created, updated when edited" do
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.parse("December 25"), creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Wish {{ contact.name }} a Merry Christmas!", template: true, step: step 
    sequence.save!
    
    sequence.generate_tasks 3.days.from_now
    sequence.generate_tasks 3.days.ago
    assert @member.tasks.count == 2
    assert @member.tasks.last.due_at.strftime("%B %-d") == "December 25"
    
    step.update offset: 3.days.to_i
    assert @member.tasks.count == 2
    assert @member.tasks.last.due_at.strftime("%B %-d") == "December 28"
    
    step.update offset: 3.days.to_i * -1
    assert @member.tasks.count == 2
    assert @member.tasks.last.due_at.strftime("%B %-d") == "December 22"
    
    sequence.generate_tasks Time.zone.parse("January 1, #{Time.zone.now.year}")
    assert @member.tasks.last.due_at.strftime("%B %-d") == "December 22"
    assert @member.tasks.count == 2
    
    sequence.generate_tasks Time.zone.parse("January 1, #{Time.zone.now.year + 1}")
    assert @member.tasks.count == 3
  end
  
  it "should add tasks when added to segment, remove tasks when removed from segment" do
    @segment = @org.segments.create! name: "New Segment", filters: []
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.parse("December 25"), creator: @member, segment_ids: [@segment.id]
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Wish {{ contact.name }} a Merry Christmas!", template: true, step: step
    
    sequence.save!
    assert @member.tasks.count == 2
    
    @new_member = @org.members.create! data: { full_name: "Billy Joe Armstrong" }
    assert_equal "December 25", @member.tasks.last.due_at.strftime("%B %-d")
    assert_equal 4, @member.tasks.count
    
    @new_member.destroy
    assert_equal 1, @org.members.count
    assert_equal 2, @member.tasks.count
  end
  
  it "should add tasks when bulk added manually to sequence" do
    sequence = @org.sequences.new strategy: "manual", creator: @member, segment_ids: [1, 2, 3]
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step

    sequence.save!
    assert @member.tasks.count == 0
    assert sequence.segment_ids == []
    
    sequence.generate_tasks Time.zone.now, [@member.id]

    assert_equal 1, @org.members.count
    assert_equal 1, @member.tasks.count
  end
  
  it "should delete tasks when bulk removed manually from sequence" do
    sequence = @org.sequences.new strategy: "manual", creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step

    sequence.save!
    sequence.generate_tasks Time.zone.now, [@member.id]
    assert @member.tasks.last.due_at.strftime("%B %-d") == Time.zone.now.strftime("%B %-d")
    assert_equal 1, @member.tasks.count
    
    sequence.remove_tasks_for [@member.id]
    assert_equal 0, @member.tasks.count
  end

  it "should add/remove tasks when contact data changes" do
    @segment = @org.segments.create! name: "New Segment", filters: [{ field: "last_name", matcher: "is", value: "Read" }]
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.parse("December 25"), creator: @member, segment_ids: [@segment.id]
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step
    
    sequence.save!
    @member.update data: @member.data.merge(last_name: "Read")
    assert_equal 1, @segment.member_ids.count
    assert_equal 2, @member.tasks.count
    
    @member.update data: @member.data.merge(last_name: "Not Read")
    assert_equal 0, @segment.member_ids.count
    assert_equal 0, @member.tasks.count
  end

  it "creates email welcome sequence tasks" do
    now = Time.zone.now
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.parse("December 25"), creator: @member
    
    5.times do |n|
      step = sequence.steps.new offset: (n * 2).days.to_i, action: "email"
      message = @org.messages.create! subject: "Subject ##{n}", body: "This is the content of the ##{n} email to {{ contact.name }}.", template: true
      step.build_task template: true, step: step, message: message
    end
    
    sequence.save!
    sequence.generate_tasks 3.days.from_now
    sequence.generate_tasks 3.days.ago
    
    assert_equal 10, @member.tasks.count
    assert_equal 2, @member.tasks.where(
      due_at: sequence.date.in_time_zone..sequence.date.in_time_zone + 3.days
    ).count
  end
  
  it "sends email immediately" do
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.now, creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "email"
    message = @org.messages.create! subject: "Awesome {{ contact.name }}", body: "This is the content of the email to {{ contact.name }}.", creator: @member, template: true
    step.build_task template: true, step: step, message: message
    
    sequence.save!
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "Awesome #{@member.name}"
    mail.body.should have_content @member.name
  end
  
  it "queues email to be sent in 3 days" do
    sequence = @org.sequences.new strategy: "annual", date: Time.zone.now, creator: @member
    
    step = sequence.steps.new offset: 3.days.to_i, action: "email"
    message = @org.messages.create! subject: "First {{ contact.name }}", body: "This is the content of the email to {{ contact.name }}.", creator: @member, template: true
    step.build_task template: true, step: step, message: message
    
    step = sequence.steps.new offset: 31.days.to_i, action: "email"
    message = @org.messages.create! subject: "Second {{ contact.name }}", body: "This is the content of the email to {{ contact.name }}.", creator: @member, template: true
    step.build_task template: true, step: step, message: message
    
    sequence.save!
    assert ActionMailer::Base.deliveries.empty?
    
    Message.deliver_overdue Time.zone.now
    assert ActionMailer::Base.deliveries.empty?
    
    Message.deliver_overdue 3.days.from_now
    Message.deliver_overdue 1.week.from_now
    Message.deliver_overdue 3.days.ago
    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "First #{@member.name}"
    
    Message.deliver_overdue 14.days.from_now
    assert_equal 1, ActionMailer::Base.deliveries.count
    
    Message.deliver_overdue 32.days.from_now
    assert_equal 2, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "Second #{@member.name}"
  end
  
  it "can create contact with attached sequence" do
    sequence = @org.sequences.new strategy: "manual", creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step
    sequence.save!
    
    assert_equal 0, Task.not_a_template.count
    
    visit example_path(@org, "save_contact", sequence_ids: [sequence.id])
    page.should have_content "Name"
    fill_in "Name", with: "Jack Sparrow"
    fill_in "Email", with: "jack@dallasread.com"
    click_button "Subscribe"
    
    page.should have_content "a"
    assert_equal 1, Task.not_a_template.count
  end
  
  it "creates tasks only for the days allotted" do
    @member.update availability: [1, 2, 3, 4, 5]
    sequence = @org.sequences.new strategy: "annual", date: DateTime.parse("Sunday"), creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step
    
    sequence.save!
    assert_equal "Monday", Task.not_a_template.first.due_at.strftime("%A")
    
    @member.update availability: [2]
    assert "Tuesday", Task.not_a_template.first.due_at.strftime("%A")
  end
  
  it "can create recurring sequences" do
    sequence = @org.sequences.new strategy: "recurring", interval: 90.days, creator: @member
    step = sequence.steps.new offset: 0.days.to_i, action: "task"
    step.build_task content: "Touch base with {{ contact.name }}.", template: true, step: step
    sequence.save!
    assert_equal 4, Task.not_a_template.count
    assert Task.not_a_template.last.content_for_contact.include? @member.name
  end

#  it "members can change they're availability if touch base module"
#  it "can't have steps with offset greater than recurrence"
#  it "creates tasks that are spread out evenly"

#  it "can holiday"

# The Plan
  # => every morning, create tasks for the next 30 days (only for recurring, date-based)
end