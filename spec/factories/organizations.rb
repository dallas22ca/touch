FactoryGirl.define do
  factory :organization do
    sequence :id do |n|
      n * 10000000
    end
    
    permalink "test-org"
    name "Test Organization"
  end
end