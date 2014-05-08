FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "test-#{n}@oneattendance.com"
    end
    
    sequence :name do |n|
      "Test Person ##{n}"
    end
    
    password "secretpassword"
  end
end