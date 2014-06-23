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
  
  it "can add member to list with sequence" do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    
    @sequence = @org.sequences.new strategy: "manual", creator_id: 1
    step = @sequence.steps.new offset: 0.days.to_i, action: "task"
    step.create_task content: "Welcome to the club, {{ contact.name }}!", template: true, step: step
    @sequence.save!
    assert 0, Task.count
    
    visit example_path(@org, "save_contact", sequence_ids: [1])
    fill_in "Name", with: "Jack Sparrow"
    fill_in "Email", with: "jack@dallasread.com"
    fill_in "Birthday", with: "April 5, 1988"
    click_button "Subscribe"

    assert 1, Task.count
    
    visit example_path(@org, "save_contact", sequence_ids: [1])
    fill_in "Name", with: "Jack Sparrow"
    fill_in "Email", with: "jack@dallasread.com"
    fill_in "Birthday", with: "April 5, 1988"
    click_button "Subscribe"

    assert 1, Task.count
  end
end