class ModulesController < ApplicationController
  before_filter :set_organization
  before_filter :check_if_org
  
  def redirect
    if @org.modules.include? "contacts"
      redirect_to contacts_path(current_user.organizations.first)
    elsif @org.modules.include? "attendance"
      redirect_to attendance_path(current_user.organizations.first)
    else
      redirect_to edit_user_registration_path
    end
  end

  def contacts
    params[:filters] ||= []
    params[:filters] = params[:filters].map { |k, v| v } if params[:filters].kind_of? Hash
    
    if params[:q]
      params[:q].split(" ").each do |word|
        q = { field: "q", matcher: "like", value: word }
        params[:filters].push q
      end
    end
    
    @members = @org.filter_members(params[:filters])
    render "modules/contacts/index"
  end
  
  def permissions
    render "modules/permissions/index"
  end
  
  def attendance
    if @org.rooms.any?
      redirect_to room_path(@org.permalink, @org.rooms.first)
    else
      render "modules/attendance/index"
    end
  end
  
  def presence
    @room = @org.rooms.find(params[:room_id])
    @meeting = @room.meetings.find(params[:meeting_id])
    @member = @org.members.where(id: params[:member_id]).first
    present = params[:member_id] == "new" || params[:present].to_s =~ /true|t|1/ ? true : false
    verb = present ? "attended" : "did not attend"
    exists = @org.events.where("data @> 'contact.key=>#{@member.key}' AND data @> 'meeting.id=>#{@meeting.id}' AND data @> 'room.id=>#{@room.id}'").first if @member

    if present
      if !exists
        if params[:member_id] == "new"
          @user = User.create!(
            name: params[:name],
            ignore_password: true,
            ignore_email: true
          )
          @member = @org.members.create! user: @user, permissions: ["member"]
        end
      
        @org.events.create!(
          description: "{{ contact.name }} #{verb} {{ room.name }}",
          verb: verb,
          created_at: @meeting.date,
          json_data: {
            present: present,
            meeting: @meeting.attributes,
            room: @room.attributes,
            contact: {
              key: @member.key
            }
          }
        )
      end
    else
      exists.destroy
    end
    
    render "modules/attendance/presence"
  end
  
  private
  
  def check_if_org
    redirect_to contacts_path(current_user.organizations.first) if !@org

    if %w[contacts permissions attendance].include? action_name
      unless @org.modules.include?(action_name) && @member.permits?(action_name)
        redirect_to root_path
      end
    end
  end
end
