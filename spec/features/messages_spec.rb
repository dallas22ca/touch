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
end