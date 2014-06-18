class ModulesController < ApplicationController
  before_filter :set_organization
  before_filter :check_if_org
  
  def redirect
    if @member.permits? :tasks, :read
    	redirect_to tasks_path(@org)
    elsif @member.permits? :members, :read
      redirect_to members_path(@member.organization)
    elsif @member.permits? :folders, :read
      redirect_to folders_path(@member.organization)
    elsif @member.permits? :rooms, :read
      redirect_to rooms_path(@member.organization)
    else
      redirect_to edit_user_registration_path
    end
  end
  
  private
  
  def check_if_org
    redirect_to new_organization_path if !@org && current_user && current_user.organizations.empty?
  end
end
