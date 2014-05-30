require 'test_helper'

class MessageMailerTest < ActionMailer::TestCase
  test "bulk" do
    mail = MessageMailer.bulk
    assert_equal "Bulk", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
