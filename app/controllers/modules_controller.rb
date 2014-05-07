class ModulesController < ApplicationController
  before_filter :set_organization
  before_filter :check_if_org
  
  def redirect
    if @org.modules.include? "Contacts"
      redirect_to contacts_path(current_user.organizations.first)
    elsif @org.modules.include? "Attendance"
      redirect_to attendance_path(current_user.organizations.first)
    end
  end

  def contacts
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
    @membership = @org.memberships.where(id: params[:membership_id]).first
    present = params[:membership_id] == "new" || params[:present].to_s =~ /true|t|1/ ? true : false
    verb = present ? "Attended" : "Did not attend"
    exists = @org.events.where("data @> 'contact.key=>#{@membership.key}' AND data @> 'meeting.id=>#{@meeting.id}' AND data @> 'room.id=>#{@room.id}'").first if @membership

    if present
      if !exists
        if params[:membership_id] == "new"
          @user = User.create!(
            name: params[:name],
            ignore_password: true,
            ignore_email: true
          )
          @membership = @org.memberships.create! user: @user, permissions: ["member"]
        end
      
        @org.events.create!(
          description: "#{verb} {{ room.name }} on {{ meeting.date }}",
          created_at: @meeting.date,
          json_data: {
            present: present,
            meeting: @meeting.attributes,
            room: @room.attributes,
            contact: {
              key: @membership.key
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

    if %w[contacts permissions attendance].include?(action_name)
      unless @membership.permits?(action_name)
        redirect_to root_path
      end
    end
  end
end
