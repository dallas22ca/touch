class EventsController < ApplicationController
  before_filter :set_organization
  
  def index
    @events = @org.events.order("created_at desc")
  end
  
  def track
    if params[:data]
      # args = JSON.parse(Base64.decode64(params[:args])).to_hash.with_indifferent_access
      # key = args[:member].delete(:key).parameterize
      # @member = @org.members.where(key: key).first_or_initialize
      # @member.update_attributes(data: @member.data.merge(args.delete(:member)))
      # @event = @member.events.new
      # @event.created_at = Time.zone.at(args.delete(:remetric_created_at).to_i) if args.has_key? :remetric_created_at
      # @event.description = args.delete(:description)
      # @event.data = args
      # @event.member_snapshot = @member.data
      # @event.user = @user
      # @event.save
    end
  end
end
