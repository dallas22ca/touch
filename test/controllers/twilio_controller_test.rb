require 'test_helper'

class TwilioControllerTest < ActionController::TestCase
  test "should get voice" do
    get :voice
    assert_response :success
  end

  test "should get sms" do
    get :sms
    assert_response :success
  end

end
