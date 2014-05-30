require "spec_helper"

describe "Examples" do
  it "can add member to list" do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    assert @org.members.count == 0
    visit example_path(@org, "save_contact")
    page.should have_content "Name"
    fill_in "Name", with: "Jack Sparrow"
    fill_in "Email", with: "jack@dallasread.com"
    fill_in "Birthday", with: "April 5, 1988"
    click_button "Subscribe"
    page.should have_content "Sparrow"
    assert @org.reload.members.count == 1
    assert @org.reload.members.first.data["birthday"] == "April 5, 1988"
  end
end