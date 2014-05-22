class ModulesController < ApplicationController
  before_filter :set_organization
  before_filter :check_if_org
  
  def redirect
    if @member.permits? :members, :read
      redirect_to members_path(@member.organization)
    elsif @member.permits? :folders, :read
      redirect_to folders_path(@member.organization)
    elsif @member.permits? :rooms, :read
      redirect_to attendance_path(@member.organization)
    else
      redirect_to edit_user_registration_path
    end
  end
  
  def attendance
    if @org.rooms.any?
      redirect_to room_path(@org, @org.rooms.first)
    else
      render "modules/attendance/index"
    end
  end
  
  private
  
  def check_if_org
    redirect_to new_organization_path if !@org
  end
end
