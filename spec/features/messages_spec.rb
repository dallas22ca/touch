require "spec_helper"

describe "Message", js: true do
  before :each do
    Sidekiq::Testing.inline!
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
  
  it "is marked as opened" do
    @opener = FactoryGirl.create(:user)
    @org.users.push @opener
    @opener = @opener.members.first
    assert Event.count == 0
    
    @message = @org.messages.create! member_ids: [@opener.id], subject: "Why?", body: "Why Not?", creator: @member
    visit open_path(@org, @message.id * CONFIG["secret_number"], @opener.id * CONFIG["secret_number"])
    assert Event.count == 1
  end
  
  it "links are parsed" do
    
  end
end