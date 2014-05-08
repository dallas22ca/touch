FactoryGirl.define do
  factory :card do
    stripe_token "cus_3pUe6WUomJgLKg"
    expiry "07/15"
    last4 "4444"
    vendor "MasterCard"
  end
end