require "spec_helper"

describe "Sequence", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["members", "messages"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  # The Plan
    # => create tasks a month in advance
  
  # methods of getting on a sequence:
    # => manual
    # => added to segment
    # => contact data changed
    # => everyone
  
  # when can a segment start
    # => Annual dates
    # => Arbitrary dates
  
  # HOW TO CREATE TASKS
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
  it "follows up once a month, then once a week, without duplicates"
  
  # MULTIPLE STAGE TASKS
  it "creates birthday sequence tasks"
end