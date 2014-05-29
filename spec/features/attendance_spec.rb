require "spec_helper"

describe "Agent", js: true do
  before :each do
    @domain = "oneattendance.com"
    page.driver.browser.set_cookie("domain=#{@domain}; path=/; domain=127.0.0.1")
    
    Organization.delete_all
    Member.delete_all
    User.delete_all
    Room.delete_all
    Meeting.delete_all
    
    @org = FactoryGirl.create(:organization, modules: ["attendance"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  it "signs up and receives correct modules" do
    sign_in @member.user
    visit rooms_path(@org)
    page.should have_content "Create A Room"
    click_link "Create A Room"
    fill_in "Name", with: "Room #1"
    assert_equal 0, @org.reload.rooms.count
    click_button "Save Room"
    sleep 1
    assert_equal 1, @org.reload.rooms.count
  end
  
  it "can create a meeting" do
    @room = @org.rooms.create name: "Room #2"
    sign_in @member.user
    visit room_path(@org, @room)
    click_link "+"
    click_button "Save Meeting"
    sleep 1
    assert_equal 1, @room.meetings.count
  end
  
  it "can create/destroy a presence event" do
    @room = @org.rooms.create name: "Room #3", creator: @member
    @meeting = @room.meetings.create date: Time.zone.now
    sign_in @member.user
    visit room_path(@org, @room)
    
    assert_equal 0, @meeting.reload.events.count
    page.should have_content "0"
    
    first(".presence_toggle").click
    sleep 1
    assert_equal 1, @meeting.reload.events.count
    page.should have_content "1"
    
    first(".presence_toggle").click  
    sleep 1
    assert_equal 0, @meeting.reload.events.count
    page.should have_content "0"
  end
  
  it "can add a member on the fly by clicking on Add" do
    @room = @org.rooms.create name: "Room #3", creator: @member
    @meeting = @room.meetings.create date: Time.zone.now
    sign_in @member.user
    visit room_path(@org, @room)
    
    fill_in "q", with: "New Person"
    assert_equal 1, @org.reload.members.count
    page.driver.browser.execute_script "$('#noterizer').hide()"
    first(".add_on_the_fly .pretty_name").click
    sleep 1
    assert_equal 2, @org.reload.members.count
    
    fill_in "q", with: "Person"
    assert_equal 2, @org.reload.members.count
    page.driver.browser.execute_script "$('#noterizer').hide()"
    first(".add_on_the_fly .pretty_name").click
    sleep 1
    assert_equal 3, @org.reload.members.count
  end
  
  it "can add a member on the fly by creating presence" do
    @room = @org.rooms.create name: "Room #4", creator: @member
    @meeting = @room.meetings.create date: Time.zone.now
    sign_in @member.user
    visit room_path(@org, @room)
    
    fill_in "q", with: "Joe"
    assert_equal 1, @org.reload.members.count
    assert page.has_css? ".present", count: 0
    
    first(".add_on_the_fly .presence_toggle").click
    sleep 1
    page.driver.browser.execute_script "$('#noterizer').hide()"
    assert_equal 2, @org.reload.members.count
    assert_equal 1, @org.reload.events.count
    assert page.should have_content "Joe"
    assert page.has_css? ".presence_toggle.present", count: 1
    
    first(".presence_toggle").click
    sleep 1
    page.driver.browser.execute_script "$('#noterizer').hide()"
    assert_equal 0, @org.reload.events.count
    assert page.has_css? ".present", count: 0
  end
  
  it "can add a room" do
    @room = @org.rooms.create name: "Room #4", creator: @member
    @meeting = @room.meetings.create date: Time.zone.now
    sign_in @member.user
    visit rooms_path(@org)
    page.should have_content "Create A Room"
    click_link "Create A Room"
    page.should have_content "Close"
  end
end