require "spec_helper"

describe "Importer", js: true do
  before :each do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
  end
  
  it "can upload a file" do
    sign_in @user
    visit members_path(@org)
    click_link "Add Contact"
    click_link "Click here to import a CSV or Excel file."
    page.should have_content "CHOOSE A CSV OR EXCEL FILE TO IMPORT"
  end
  
  it "parses a good file" do
    Sidekiq::Testing.fake!
    sign_in @user
    @org.members_import = File.new "#{Rails.root}/spec/assets/importer/good.csv"
    @org.save!
    assert @org.importing?
    assert ImportWorker.jobs.size == 1
    visit members_path(@org)
    
    sleep 1
    page.should have_content "importing your contacts"
    ImportWorker.drain
    assert !@org.reload.importing?
    assert !@org.reload.members_import.exists?
    
    sleep 2
    page.should have_content @org.members.last.data["first_name"]
    assert @org.reload.members.count == 7
    
    @org.update members_import: File.new("#{Rails.root}/spec/assets/importer/good.csv")
    ImportWorker.drain
    sleep 2
    assert @org.reload.members.count == 7
  end
  
  it "parses handles a bad file" do
    Sidekiq::Testing.fake!
    sign_in @user
    @org.members_import = File.new "#{Rails.root}/spec/assets/importer/bad.csv"
    @org.save!
    ImportWorker.drain
    sleep 2
    page.should have_content "Please re-upload."
  end
  
  it "can add a single contact" do
    sign_in @user
    visit members_path(@org)
    click_link "Add Contact"
    fill_in "First Name", with: "Awesome"
    click_button "Save Member"
    sleep 0.5
    assert @org.members.count == 2
  end
end
