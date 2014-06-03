require "spec_helper"

describe "Tasks", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["tasks"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end

  it "shows incomplete tasks for today and future" do
    sign_in @member.user
    task = Task.create creator: @member, content: "My new Task", member: @member
    
    visit tasks_path(@org)
    page.source.should have_content task.content
    
    visit tasks_path(@org, date: 3.days.from_now.strftime("%d-%m-%Y"))
    page.source.should have_content task.content
    
    visit tasks_path(@org, date: 3.days.ago.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
    
    task.delete
    task = Task.create creator: @member, content: "My new Task", member: @member, due_at: Time.zone.now
    
    visit tasks_path(@org)
    page.source.should have_content task.content
    
    visit tasks_path(@org, date: 3.days.from_now.strftime("%d-%m-%Y"))
    page.source.should have_content task.content
    
    visit tasks_path(@org, date: 3.days.ago.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
  end
  
  it "shows completed tasks only on day completed" do
    sign_in @member.user
    task = Task.create creator: @member, content: "My new Task", member: @member, complete: true
    
    assert task.completed_at != nil

    visit tasks_path(@org)
    page.source.should have_content task.content
    
    visit tasks_path(@org, date: 3.days.from_now.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
    
    visit tasks_path(@org, date: 3.days.ago.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
    
    task.update completed_at: 3.days.ago
    
    visit tasks_path(@org)
    page.source.should_not have_content task.content
    
    visit tasks_path(@org, date: 3.days.from_now.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
    
    visit tasks_path(@org, date: 3.days.ago.strftime("%d-%m-%Y"))
    page.source.should_not have_content task.content
  end
  
  it "shows previous incomplete tasks" do
    sign_in @member.user
    time = 1.day.ago
    task = Task.create creator: @member, content: "My new Task", member: @member, due_at: time
    visit tasks_path(@org)
    page.should have_content "Overdue from #{time.strftime("%A, %b %-d")}"
  end
  
  it "click on date to time travel" do
    sign_in @member.user
    visit tasks_path(@org)
    page.should have_content 1.day.ago.strftime("%a, %b %-d")
    page.should have_content 1.day.from_now.strftime("%a, %b %-d")
  end
  
  # it "tasks have contact details" do
  #   assert "Aweosme"
  # end
end