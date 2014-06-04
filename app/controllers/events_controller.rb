class EventsController < ApplicationController
  protect_from_forgery except: :save_member
  before_filter :set_organization, except: :save_member
  
  def index
    @events = @org.events.order("created_at desc")
  end
  
  def save_member
    member = params[:member]
    member = params[:contact] if !member && params[:contact]
    
    @org = Organization.where(permalink: params[:permalink], publishable_key: params[:publishable_key]).first
    
    if @org
      @this_member = @org.members.where(key: member[:key]).first if member.has_key?(:key)
      @this_member = @org.members.where("data -> 'email' = ?", member[:email]).first if member.has_key?(:email) && !@this_member
      @this_member = @org.members.new if !@this_member
      @this_member.created_at = member.delete :created_at if member.has_key? :created_at
      @this_member.data = @this_member.data.merge member
      @this_member.data["full_name"] = member.delete :name
    end

    if @this_member && @this_member.save
      render json: { success: true, member: @this_member }
    else
      render json: { success: false }
    end
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
