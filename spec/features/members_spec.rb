require "spec_helper"

describe "Member" do
  it "parses the name properly" do
    @org = FactoryGirl.create(:organization, modules: ["attendance"])
    member = @org.members.create(full_name: "Joe")
    assert_equal "Joe", member.data["first_name"]
  end
  
  it "parses the name properly" do
    @org = FactoryGirl.create(:organization, modules: ["attendance"])
    member = @org.members.create(full_name: "Joe Schmoe")
    assert_equal "Joe", member.data["first_name"]
    assert_equal "Schmoe", member.data["last_name"]
  end
  
  it "parses the name properly" do
    @org = FactoryGirl.create(:organization, modules: ["attendance"])
    member = @org.members.create(full_name: "Joe Schmoe II")
    assert_equal "Joe", member.data["first_name"]
    assert_equal "Schmoe II", member.data["last_name"]
  end
  
  it "visits the unsubscribe path" do
    @org = FactoryGirl.create(:organization, modules: ["attendance"])
    member = @org.members.create(full_name: "Joe Schmoe II")
    token = member.id * CONFIG["secret_number"]
    visit unsubscribe_path(@org, token)
    page.should have_content "You are now un-subscribed."
    visit unsubscribe_path(@org, token)
    page.should have_content "You are now re-subscribed."
  end
end