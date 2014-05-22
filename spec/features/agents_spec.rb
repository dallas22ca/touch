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
    click_button "Sign Up"
    
    fill_in "Name", with: "RLP"
    fill_in "Permalink", with: "rlp"
    click_button "Save Organization"
    
    page.should have_content "Folders"
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
  
  it "client accepts invitation with an existing, unlinked membership" do
    client = FactoryGirl.create(:user)
    @org.users.push client
    
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    @foldership = @folder.folderships.create! preset: "documents_only", name: "Random Person", email: "random@realtxn.com", creator: @member
    assert !@foldership.accepted?
    
    visit foldership_invitation_path(@org, @foldership.token)
    current_url.should have_content new_user_registration_path(token: @foldership.token)

    click_link "Sign In"
    fill_in "Email", with: client.email
    fill_in "Password", with: client.password
    click_button "Sign In"
    sleep 0.5

    assert @foldership.reload.accepted?
    visit root_path
    page.should have_content @folder.name
    page.should_not have_content "Tasks"
    page.should have_content "Documents"
  end
  
  it "client accepts invite with new, unlinked account" do
    client = FactoryGirl.create(:user)
    
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    @foldership = @folder.folderships.create! preset: "read_only", name: "Client Name", email: "client.email@realtxn.com", creator: @member
    assert !@foldership.accepted?
    
    visit foldership_invitation_path(@org, @foldership.token)
    current_url.should have_content new_user_registration_path(token: @foldership.token)
    
    page.should have_xpath("//input[@value='#{@foldership.name}']")
    assert_equal @foldership.token, find("#user_invitation_token", visible: false).value
    
    fill_in "Password", with: "secret123"
    fill_in "user_password_confirmation", with: "secret123"
    click_button "Sign Up"
    
    sleep 0.5
    assert @foldership.reload.accepted?

    visit root_path
    page.should have_content @folder.name
    page.should have_content "Tasks"
    page.should_not have_content "Create A Folder"
    
    visit folder_homes_path(@org, @folder)
    page.should_not have_content "Add A Home"
    page.should have_content "Show Map"
  end
  
  it "folder permissions hold up" do
    @folder = @org.folders.create creator: @member, name: "Wow"
    @foldership = @folder.folderships.first
    
    sign_in @user
    
    visit folder_path(@org, @folder)
    page.should have_content "Tasks"
    
    @foldership.update roles: @foldership.roles - ["tasks/read"]
    visit folder_path(@org, @folder)
    page.should_not have_content "Tasks"
    
    @member.update roles: []
    visit folder_path(@org, @folder)
    page.should have_content "AVATAR"
  end
  
  it "they can see the folders they're supposed to" do
    @folder = @org.folders.create creator_id: 11, name: "Inaccessible"
    sign_in @user
    visit folders_path(@org, @folder)
    page.should_not have_content @folder.name
  end
  
  it "they can't create folders if just client" do
    client = FactoryGirl.create(:user)
    @org.users.push client
    @client = client.members.first
    @folder = @org.folders.create name: "New Folder", creator: @member, organization: @org
    @foldership = @folder.folderships.create! preset: "read_only", member: @client, creator: @member, accepted: true
    
    sign_in client
    visit new_folder_path(@org)
    page.should_not have_content "Copy tasks from a template"
  end
end