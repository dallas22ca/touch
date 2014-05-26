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
    sleep 0.5
    assert_equal 1, @org.reload.rooms.count
  end
  
  it "can create a meeting" do
    @room = @org.rooms.create name: "Room #2", creator: @member
    sign_in @member.user
    visit room_path(@org, @room)
    click_link "+"
    click_button "Save Meeting"
    sleep 0.5
    assert_equal 1, @room.meetings.count
  end
  
  it "can create a presence event" do
    @room = @org.rooms.create name: "Room #3", creator: @member
    @meeting = @room.meetings.create date: Time.zone.now, creator: @member
    sign_in @member.user
    visit room_path(@org, @room)
    first(".presence_toggle").click
  end
  
  it "can destroy a presence event"
  it "can add a member on the fly by clicking on Add"
  it "can add a member on the fly by creating presence"
end