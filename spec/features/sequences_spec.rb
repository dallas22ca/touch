require "spec_helper"

describe "Sequence", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["members", "messages"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  # The Plan
    # => every morning, create tasks for the next 30 days (only for recurring, date-based)
  
  # WHEN TO CREATE TASKS
  it "should add tasks when sequence is created"
  it "should add/remove tasks when sequence is updated"

  it "should delete tasks when removed from segment"
  it "should add tasks when added to segment"
  
  it "should delete tasks when bulk removed from segment"
  it "should add tasks when bulk added to segment"

  it "should remove tasks when contact data changes"
  it "should add tasks when contact data changes"

  it "should remove tasks when manually removed from sequence"
  it "should add tasks when manually added to sequence"

  # SIMPLE FOLLOWUPS
  it "creates task 2 weeks after every birthday, then 1 week, then 3 weeks, without duplicates"
  it "sends email 5 days before December 25, then 7 days, then 3 days, without duplicates"
  it "creates a once a month, then once a week, without duplicates"
  it "creates a once a week, then once a month, without duplicates"
  it "creates tasks only for the days allotted"
  it "creates tasks that are spread out evenly"
  
  # MULTIPLE STAGE TASKS
  it "creates birthday sequence tasks"
  it "creates welcome sequence tasks"
  it "creates course sequence tasks"
  it "can't have steps with offset greater than recurrence"
end