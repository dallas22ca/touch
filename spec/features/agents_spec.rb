require "spec_helper"

describe "Agent", js: true do
  before :each do
    @domain = "realtxn.com"
    page.driver.browser.set_cookie("domain=#{@domain}; path=/; domain=127.0.0.1")
    
    Organization.delete_all
    Member.delete_all
    User.delete_all
    
    @org = FactoryGirl.create(:organization, modules: ["folders"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  it "signs up and receives correct modules" do
    visit new_user_registration_path
    fill_in "Name", with: "Joe Schmoe"
    fill_in "Email", with: "joeschmoe77@realtxn.com"
    fill_in "Password", with: "joeschmoe77"
    fill_in "user_password_confirmation", with: "joeschmoe77"
    fill_in "Permalink", with: "joe"
    click_button "Sign Up"
    page.should have_content "Folders"
    page.should have_content "Contacts"
  end
  
  it "sets the domain cookie" do
    visit new_user_session_path
    assert_equal @domain, page.all("input#domain", visible: false).first.value
  end
  
  it "can create a folder" do
    sign_in @user
    visit root_path
    page.should have_content "Folders"
    click_link "Folders"
    click_link "Create A Folder"
    fill_in "Name", with: "My New Folder"
    click_button "Save Folder"
    
    ["My New Folder", "Newsfeed", "Tasks", "Homes", "Documents", "Who's Here?", "Folder Settings"].each do |content|
      page.should have_content content
    end
  end
  
  it "simple member cannot see folders or log in" do
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    sign_in @user
    visit root_path
    page.should_not have_content "Folders"
    visit folders_path(@org)
    page.should_not have_content "Create A Folder"
  end
  
  it "cannot see contacts if not an allowed module" do
    sign_in @user
    visit members_path(@org)
    page.should_not have_content "FIRST NAME"
    @org.update modules: ["members"]
    visit members_path(@org)
    page.should have_content "FIRST NAME"
  end
  
  it "invites client" do
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    sign_in @user
    visit folder_folderships_path(@org, @folder)
    click_link "Send An Invitation"
    fill_in "Name", with: "Joe Schmoe"
    fill_in "Email", with: "joeschmoe-#{rand(4444..333333)}@realtxn.com"
    select "Client (read-only access)", from: "Access Level"
    click_button "Send Invitation"
    
    sleep 0.2
    Capybara.reset_sessions!
    mail = ActionMailer::Base.deliveries.last
    @foldership = @folder.folderships.last
    assert_equal "Joe Schmoe", @foldership.name
    assert @foldership.roles.include?("comments/read")
    mail.body.should have_content foldership_invitation_path(@org, @foldership.token)
  end
  
  it "client accepts invitation with existing, linked membership" do
    client = FactoryGirl.create(:user)
    @org.users.push client
    @client = client.members.first
    
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    @foldership = @folder.folderships.create! preset: "read_only", member: @client, creator: @member
    assert !@foldership.accepted?
    
    visit foldership_invitation_path(@org, @foldership.token)
    current_url.should have_content new_user_registration_path(token: @foldership.token)
    
    sign_in client
    visit foldership_invitation_path(@org, @foldership.token)

    assert @foldership.reload.accepted?
    visit root_path
    page.should have_content @folder.name
  end
  
  it "client accepts invite with existing, unlinked account" do
    client = FactoryGirl.create(:user)
    @client = client.members.first
    
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    @foldership = @folder.folderships.create! preset: "read_only", name: "client.name", email: "client.email", creator: @member
    assert !@foldership.accepted?
    
    visit foldership_invitation_path(@org, @foldership.token)
    current_url.should have_content new_user_registration_path(token: @foldership.token)
    
    # Sign up process for name (prepop), email (prepop), password
    # FB?

    assert @foldership.reload.accepted?
    visit root_path
    page.should have_content @folder.name
  end
  
  # they can see the folders they're supposed to
  # they can't create folders if just client
  # permissions actually hold up
end