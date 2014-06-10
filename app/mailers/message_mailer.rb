class MessageMailer < ActionMailer::Base
  def bulk(message_id, member_id, task_id = false)
    verb = "received"
    @message = Message.find(message_id)
    @task = @message.creator.tasks.find(task_id) unless task_id.blank?
    @member = @message.organization.members.find(member_id)

    if @member
      @contact_token = @member.id * CONFIG["secret_number"]
      @message_token = @message.id * CONFIG["secret_number"]
      
      if mail(
          from: @message.creator.name_and_email,
          to: @member.name_and_email,
          subject: Message.content_for(@message.subject, @member)
        )
        
        @event = @message.organization.events.new(
          description: "{{ member.name }} #{verb} {{ message.subject }}",
          verb: verb,
          json_data: {
            message: @message.attributes,
            member: {
              key: @member.key
            }
          }
        )
        
        if @task
          @task.update complete: true
          @event.json_data[:task] = @task.attributes
        end

        @event.save
      end
    end
  end
end
