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
  
  private
  
  def check_if_org
    redirect_to contacts_path(current_user.organizations.first) if !@org
  end
end
