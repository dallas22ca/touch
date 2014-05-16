class ChannelMailer < ActionMailer::Base
  default from: "no-reply@realtxn.com"
  
  def invitation(channelship_id)
    @channelship = Channelship.find(channelship_id)
    @channel = @channelship.channel
    @member = @channelship.member
    @inviter = @channelship.creator

    mail to: @member.name_and_email, subject: "You've been invited to a channel"
  end
end
