require "spec_helper"

describe "Filter" do
  before :each do
    Organization.delete_all
    Member.delete_all
    User.delete_all    
  end
  
  it "default returns all" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.users.push FactoryGirl.create(:user) }
    assert_equal 5, @org.filter_members.count
  end
  
  it "searches field with simple ilike" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.users.push FactoryGirl.create(:user) }
    assert_equal 1, @org.filter_members([{
      field: "last_name",
      matcher: "like",
      value: "#{@org.members.first.data["last_name"]}"
    }]).count
  end
  
  it "searches events field with simple greater_than" do
    @org = FactoryGirl.create(:organization)
    5.times.map { |n| @org.users.push FactoryGirl.create(:user) }
    
    @org.members.each_with_index do |m, n|
      m.update data: { favourite_number: (n + 1).to_s }
    end
    
    assert_equal 1, @org.filter_members([{
      field: "favourite_number",
      matcher: "greater_than",
      value: "4"
    }]).count
  end
  
  it "searches events field where occurances is greater_than" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.users.push FactoryGirl.create(:user) }
    
    @org.members.each_with_index do |m, n|
      (10 - n).times do
        @org.events.create!(
          description: "{{ member.name }} attended {{ room.name }}",
          verb: "attended",
          json_data: {
            present: "true",
            room: {
              name: "Test Conference"
            },
            member: {
              key: m.key
            }
          }
        )
      end
    end
    
    assert_equal 5, @org.filter_members([{
      field: "occurances",
      event: "attended",
      matcher: "greater_than",
      value: "1"
    }]).count
    
    assert_equal 5, @org.filter_members([{
      field: "occurances",
      event: "attended",
      matcher: "less_than",
      value: "11"
    }]).count
    
    assert_equal 1, @org.filter_members([{
      field: "occurances",
      event: "attended",
      matcher: "is",
      value: "7"
    }]).count
    
    assert_equal @org.members.first, @org.filter_members([{
      field: "occurances",
      event: "attended",
      matcher: "is",
      value: "10"
    }]).first
  end
end