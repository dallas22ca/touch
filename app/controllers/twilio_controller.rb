class TwilioController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :find_latest_member

  def voice
    response = ::Twilio::TwiML::Response.new do |r|
      r.Say "Thanks for contacting #{@org.name}. We will contact you as soon as we can.", voice: "alice"
    end
    
    client = Twilio::REST::Client.new CONFIG["twilio_account_sid"], CONFIG["twilio_auth_token"]
    client.account.messages.create(
      from: @from,
      to: Member.prepare_phone(@creator.data["mobile"]),
      body: "#{@member.name} (#{@member.data["mobile"]}) has just tried to call your messaging number."
    )
  
    render text: response.text
  end

  def sms
    client = ::Twilio::REST::Client.new CONFIG["twilio_account_sid"], CONFIG["twilio_auth_token"]
    response = client.account.messages.create(
      from: @from,
      to: Member.prepare_phone(@creator.data["mobile"]),
      body: "#{@member.name} (#{@member.data["mobile"]}) said, \"#{params[:Body]}\""
    )
    
    render text: "Message received from #{@member.name} (#{@member.data["mobile"]})."
  end
  
  private
  
  def find_latest_member
    @event = Event.delivered.for_mobile(params[:From]).order("created_at desc").first
    
    if @event
      @member = @event.member
      @org = @event.organization
      @message = @org.messages.find @event.data["message.id"]
      @creator = @message.creator
      @from = Message.phone_numbers[@org.id % Message.phone_numbers.size]
      Message.create_reply_for @message.id, @member.id, nil
    else
      render text: "No member found."
    end
  end
end
