class ModulesController < ApplicationController
  before_filter :set_organization
  before_filter :check_if_org
  
  def redirect
    redirect_to contacts_path(current_user.organizations.first)
  end

  def contacts
    render "modules/contacts/index"
  end
  
  def attendance
    if @org.rooms.any?
      redirect_to room_path(@org.permalink, @org.rooms.first)
    else
      render "modules/attendance/index"
    end
  end
  
  def presence
    room = @org.rooms.find(params[:room_id])
    meeting = room.meetings.find(params[:meeting_id])
    membership = @org.memberships.find(params[:membership_id])
    present = params[:present].to_s =~ /true|t|1/ ? true : false
    verb = present ? "Attended" : "Did not attend"
    
    @org.events.create!(
      description: "#{verb} {{ room.name }} on {{ meeting.date }}",
      json_data: {
        present: present,
        meeting: meeting,
        room: room,
        contact: membership.user
      }
    )
    
    render "modules/attendance/presence"
  end
  
  private
  
  def check_if_org
    redirect_to contacts_path(current_user.organizations.first) if !@org
  end
end
