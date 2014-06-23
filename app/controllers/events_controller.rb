class EventsController < ApplicationController
  protect_from_forgery except: [:members_save, :events_save, :track]
  before_filter :set_organization, except: [:members_save, :events_save, :track]
  
  def index
    @events = @org.events.order("created_at desc")
  end
  
  def members_save
    member = params[:member]
    member = params[:contact] if !member && params[:contact]
    
    @org = Organization.where(publishable_key: params[:publishable_key]).first
    
    if @org
      @this_member = @org.members.where(key: member[:key]).first if member.has_key?(:key)
      @this_member = @org.members.where("data -> 'email' = ?", member[:email]).first if member.has_key?(:email) && !@this_member
      @this_member = @org.members.new if !@this_member
      @this_member.sequence_ids = params[:sequence_ids] if params[:sequence_ids]
      @this_member.created_at = member.delete :created_at if member.has_key? :created_at
      @this_member.data = @this_member.data.merge member
      @this_member.data["full_name"] = member.delete :name
    end

    if @this_member && @this_member.save
      if params[:redirect]
        redirect_to params[:redirect]
      else
        render json: { success: true, member: @this_member }
      end
    else
      if params[:redirect]
        redirect_to params[:redirect]
      else
        render json: { success: false }
      end
    end
  end
  
  def events_save
    begin
      create_event_from_args params
    rescue
    end
    
    if @event && @event.save
      if !@redirect.blank?
        redirect_to @redirect
      else
        render json: { success: true, member: @this_member, event: @event }
      end
    else
      if !@redirect.blank?
        redirect_to @redirect
      else
        render json: { success: false }
      end
    end
  end
  
  def track
    begin
      args = JSON.parse(Base64.decode64(params[:args])).to_hash.with_indifferent_access
      create_event_from_args args
      @event.save
    rescue
    end
    
    if !@redirect.blank?
      redirect_to @redirect
    else
      send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
    end
  end
  
  private
  
  def create_event_from_args(args)
    @redirect = args.delete :redirect
    member_args = args[:member]
    member_args = args[:contact] if member_args.blank?
    member_args = member_args.with_indifferent_access
    key = "#{member_args.delete(:key)}".parameterize
    @org = Organization.where(publishable_key: args.delete(:publishable_key)).first
    
    if key.blank?
      @this_member = @org.member.new
    else
      @this_member = @org.members.where(key: key).first_or_initialize
    end
    
    @this_member.data = @this_member.data.merge(member_args)
    @this_member.save

    @event = @org.events.new(
      description: args.delete(:description),
      verb: args.delete(:verb),
      json_data: args.merge({ member: { key: @this_member.key } })
    )

    @event.created_at = Time.zone.at(args.delete(:event_created_at).to_i) if args.has_key? :event_created_at
  end
end
