class MembersController < ApplicationController
  before_filter :set_organization
  
  def index
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
  
  def edit
    @member = @org.members.find(params[:id])
  end
end
