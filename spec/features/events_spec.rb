require "spec_helper"

describe "Events" do
  it "linked_story links to members" do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
    @message = @org.messages.create! member_ids: [@member.id], subject: "Why?", body: "You should go to!", creator: @member
    verb = "opened"
    
    event = @org.events.create!(
      description: "{{ member.name }} #{verb} {{ message.subject }}",
      verb: verb,
      json_data: {
        message: @message.attributes,
        member: {
          key: @member.key
        }
      }
    )

    assert event.linked_story.include? "/members/#{@member.id}"
    assert event.linked_story.include? "/messages/#{@message.id}"
  end
end