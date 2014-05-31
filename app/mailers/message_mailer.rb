class MessageMailer < ActionMailer::Base
  def bulk(message_id, member_id)
    @message = Message.find(message_id)
    @member = @message.organization.members.find(member_id)
    
    if @member
      @contact_token = @member.id * CONFIG["secret_number"]
      @message_token = @message.id * CONFIG["secret_number"]
      
      if mail(
          from: @message.creator.name_and_email,
          to: @member.name_and_email,
          subject: Message.content_for(@message.subject, @member)
        )
        
        verb = "was sent"

        @message.organization.events.create(
          description: "{{ message.subject }} #{verb} to {{ member.name }}",
          verb: verb,
          json_data: {
            message: @message.attributes,
            member: {
              key: @member.key
            }
          }
        )
      end
    end
  end
end
