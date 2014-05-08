require "spec_helper"

describe "Filter" do
  before :each do
    Organization.delete_all
    Member.delete_all
    User.delete_all    
  end
  
  it "default returns all" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.members.push FactoryGirl.create(:user) }
    assert_equal 5, @org.members.filter.count
  end
  
  it "searches field with simple ilike" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.members.push FactoryGirl.create(:user) }
    assert_equal 1, @org.members.filter([{
      field: "last_name",
      matcher: "like",
      value: "#{@org.members.first.data["last_name"]}"
    }]).count
  end
  
  it "searches events field with simple greater_than" do
    @org = FactoryGirl.create(:organization)
    5.times.map { |n| @org.members.push FactoryGirl.create(:user) }
    
    @org.members.each_with_index do |m, n|
      m.update data: { favourite_number: (n + 1).to_s }
    end
    
    assert_equal 1, @org.members.filter([{
      field: "favourite_number",
      matcher: "greater_than",
      value: "4"
    }]).count
  end
  
  it "searches events field where occurances is greater_than" do
    @org = FactoryGirl.create(:organization)
    5.times.map { @org.members.push FactoryGirl.create(:user) }
    
    @org.members.each_with_index do |m, n|
      n.times do
        @org.events.create!(
          description: "{{ contact.name }} attended {{ room.name }}",
          verb: "attended",
          json_data: {
            present: "true",
            room: {
              name: "Test Conference"
            },
            contact: {
              key: m.key
            }
          }
        )
      end
    end
    
    assert_equal 1, @org.members.filter([{
      field: "events.occurances",
      event: "attended",
      matcher: "greater_than",
      value: "5"
    }]).count
  end
  
  # {
  #       field: "first_name",
  #       matcher: "like",
  #       value: "owen"
  #     }, , {
  #       event: "attended",
  #       field: "events.occurances",
  #       matcher: "less_than",
  #       value: "15"
  #     }
end