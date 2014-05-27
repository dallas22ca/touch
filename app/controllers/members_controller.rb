class MembersController < ApplicationController
  before_filter :set_organization
  before_action :set_this_member, only: [:show, :edit, :update, :destroy]
  before_filter :redirect_to_root, unless: Proc.new { @member.permits? :members, action_type }
  
  def index
    params[:filters] ||= []
    params[:filters] = params[:filters].map { |k, v| v } if params[:filters].kind_of? Hash
  
    if params[:q]
      params[:q].split(" ").each do |word|
        q = { field: "q", matcher: "like", value: word }
        params[:filters].push q
      end
    end
    
    if params[:segment_id]
      @segment = @org.segments.find(params[:segment_id])
      # @segment.filters.map { |f| params[:filters].push f } if @segment && !@segment.filters.blank?
    end
    
    if request.format == :js
      @members = @org.filter_members(params[:filters]).last_name_asc
    else
      @members = []
    end
  end
  
  def create
    @this_member = @org.members.new(member_params)

    respond_to do |format|
      if @this_member.save
        format.html { redirect_to members_path(@org), notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @this_member }
        format.js
      else
        format.html { render :new }
        format.json { render json: @this_member.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |format|
      if @this_member.update(member_params)
        format.html { redirect_to member_path(@org, @this_member), notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @this_member }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @this_member.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def destroy
    @this_member.destroy
    respond_to do |format|
      format.html { redirect_to members_path(@org), notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  private
  
  def set_this_member
    @this_member = @org.members.find(params[:id])
  end
  
  def member_params
    params.require(:member).permit(:key, :full_name).tap do |whitelisted|
      whitelisted[:data] = params[:member][:data]
    end
  end
end
