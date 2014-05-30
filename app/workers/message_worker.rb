class MessageWorker
  include Sidekiq::Worker

  sidekiq_options queue: "MessageWorker"
  
  def perform(message_id, type, args = {})
    if type == "deliver"
      MessageMailer.bulk(message_id, args["member_id"]).deliver
    end
  end
end