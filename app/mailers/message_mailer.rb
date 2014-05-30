class MessageMailer < ActionMailer::Base
  default from: "from@example.com"

  def bulk(message_id, member_id)
    @message = Message.find(message_id)
    @member = @message.organization.members.find(member_id)
    
    if @member
      @unsubscribe_token = @member.id * CONFIG["secret_number"]
      
      mail(
        from: @message.creator.name_and_email,
        to: @member.name_and_email,
        subject: @message.subject
      )
    end
  end
end
