require "spec_helper"

describe "Homer" do
  it "retrieves a list of possible options" do
    h = Homer.new
    p h.search("21 Mackenzie Street")
  end
  
  it "retrieves listing information" do
    h = Homer.new(true)
    data = h.find("21 Mackenzie Street")
    assert_equal 21, data["photos"].size
    assert_equal 2, data["beds"].to_i
    assert_equal 1, data["baths"].to_i
    assert_equal "$125,900", data["price"]
  end
end