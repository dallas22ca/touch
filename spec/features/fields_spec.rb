require "spec_helper"

describe "Fields" do
  it "adds default fields to a new organization" do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    assert @org.fields.count == 3
  end
  
  it "updates fields when a member receives new data" do
    @org = FactoryGirl.create(:organization, modules: ["members"])
    @user = FactoryGirl.create(:user)
    @org.users.push @user
    @member = @user.members.first
    @member.update(data: { 
      first_name: "Joe", 
      last_name: "Schmoe", 
      email: "joe@realtxn.com", 
      birthday: "April 5, 1988"
    })
    assert @org.fields.count == 4
    assert @org.fields.pluck(:name).include? "Birthday"
  end
end