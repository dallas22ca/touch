class MessageMailer < ActionMailer::Base
  def bulk(message_id, member_id)
    @message = Message.find(message_id)
    @member = @message.organization.members.find(member_id)
    
    if @member
      @contact_token = @member.id * CONFIG["secret_number"]
      @message_token = @message.id * CONFIG["secret_number"]
      
      mail(
        from: @message.creator.name_and_email,
        to: @member.name_and_email,
        subject: Message.content_for(@message.subject, @member)
      )
    end
  end
end
