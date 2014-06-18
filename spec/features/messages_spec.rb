require "spec_helper"

describe "Message", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["members", "messages"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  it "is sent to one person" do
    sign_in @user
    visit members_path(@org)
    click_link @member.data["email"]
    click_link "Send Message"
    fill_in "Subject", with: "What a message!"
    fill_in "Message", with: "Entirely awesome message!"
    find("#new_message input[type='submit']").click
    assert 1, @org.messages.count
    sleep 0.5
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "What a message!"
  end
  
  it "can send a message to all contacts" do
    assert 0, @org.messages.count
    sign_in @user
    visit members_path(@org)
    click_link "Send A Message"
    page.check "message_segment_all"
    fill_in "Subject", with: "What a message!"
    fill_in "Message", with: "Entirely awesome message!"
    find("#new_message input[type='submit']").click
    sleep 0.5
    assert 1, @org.messages.count
    assert @org.reload.messages.first.segment_ids == [0]
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "What a message!"
  end
  
  it "can send a message to a segment" do
    @segment = @org.segments.create name: "First Name like Test", filters: [{ field: "first_name", matcher: "like", search: "test" }]
    sign_in @user
    visit members_path(@org)
    click_link "Send A Message"
    page.uncheck "message_segment_all"
    page.check "message_segment_#{@segment.id}"
    fill_in "Subject", with: "What a message!"
    fill_in "Message", with: "Entirely awesome message!"
    find("#new_message input[type='submit']").click
    sleep 0.5
    assert 1, @org.messages.count
    assert @org.reload.messages.first.segment_ids == [@segment.id]
    mail = ActionMailer::Base.deliveries.last
    mail.subject.should have_content "What a message!"
  end
  
  it "is marked as opened" do
    Event.delete_all
    @opener = FactoryGirl.create(:user)
    @org.users.push @opener
    @opener = @opener.members.first
    assert @org.reload.events.count == 0
    
    @message = @org.messages.create! member_ids: [@opener.id], subject: "Why?", body: "Why Not?", creator: @member
    assert @org.reload.events.count == 1
    visit open_path(@org, @message.id * CONFIG["secret_number"], @opener.id * CONFIG["secret_number"])
    assert @org.reload.events.count == 2
  end
  
  it "is isn't sent to unemailable" do
    Event.delete_all
    @opener = FactoryGirl.create(:user)
    @org.users.push @opener
    @opener = @opener.members.first
    @opener.update subscribed: false
    @message = @org.messages.create! member_ids: [@opener.id], subject: "Why?", body: "Why Not?", creator: @member
    assert_equal 0, @org.reload.events.count
  end
  
  it "links are parsed" do
    @clicker = FactoryGirl.create(:user)
    @org.users.push @clicker
    @clicker = @clicker.members.first
    assert @org.reload.events.count == 0
    
    site = "http://fifa.com"
    @message = @org.messages.create! member_ids: [@clicker.id], subject: "Why?", body: "You should go to #{site}", creator: @member
    assert @org.reload.events.count == 1
    assert @message.linked_body_for(@member).include? "<a href"
    assert @message.linked_body_for(@member).include? "/0?href="
    assert @message.linked_body_for(@member).include? click_path(@org, @message.id * CONFIG["secret_number"], @member.id * CONFIG["secret_number"], 0)
    
    visit click_path(@org, @message.id * CONFIG["secret_number"], @member.id * CONFIG["secret_number"], 0, href: site, format: :gif)
    assert @org.reload.events.count == 3
    assert @message.reload.deliveries.count == 1
    page.should have_content "FIFA"
  end
  
  it "can send a message via SMS" do
    @org.members.each do |member|
      member.update data: member.data.merge(mobile: "+19029997606")
    end
    sign_in @user
    visit members_path(@org)
    click_link "Send A Message"
    fill_in "Message", with: "Entirely awesome message!"
    select "SMS", from: "message_via"
    find("#new_message input[type='submit']").click
    sleep 0.5
    assert @org.messages.last.via == "sms"
    assert ActionMailer::Base.deliveries.empty?
    assert_equal 1, @org.reload.messages.last.deliveries.count
    assert_equal "sms", Event.last.data["message.via"]
  end
  
  it "can't send an SMS to unsmsable" do
    sign_in @user
    visit members_path(@org)
    click_link "Send A Message"
    fill_in "Subject", with: "What a message!"
    fill_in "Message", with: "Entirely awesome message!"
    select "SMS", from: "message_via"
    find("#new_message input[type='submit']").click
    sleep 2
    assert @org.messages.last.via == "sms"
    assert ActionMailer::Base.deliveries.empty?
    assert_equal 0, @org.reload.messages.last.deliveries.count
  end
  
  it "parses phone numbers" do
    assert_equal "+19029997606", Member.prepare_phone("(902) 999-7606")
    assert_equal "+19029997606", Member.prepare_phone("902.999.7606")
    assert_equal "+19029997606", Member.prepare_phone("902 -999-7606")
    assert_equal "+19029997606", Member.prepare_phone("1(902)999-7606")
    assert_equal "+19029997606", Member.prepare_phone("1.902.999.7606")
  end
end