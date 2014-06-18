class MessageWorker
  include Sidekiq::Worker

  sidekiq_options queue: "MessageWorker"
  
  def perform(message_id, type, args = {})
    if type == "deliver"
      case args["via"]
      when "email"
        MessageMailer.bulk(message_id, args["member_id"], args["task_id"]).deliver
      when "sms"
        Message.send_as_sms(message_id, args["member_id"], args["task_id"])
      end
    end
  end
end