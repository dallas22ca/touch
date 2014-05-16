class ChannelshipsController < ApplicationController
  layout :choose_layout
  before_action :set_organization, except: [:accept]
  before_action :set_channel_with_permissions, except: [:index, :accept]
  before_action :set_fship, only: [:show, :edit, :update, :destroy]
  
  def index
    @channelships = @member.channelships.unaccepted
  end
  
  def new
    @fship = Channelship.new
    render nothing: true unless @channelship.permits?(:channelships, :write)
  end
  
  def create
    @fship = @channel.channelships.new(channelship_params)
    @fship.creator = @member

    respond_to do |format|
      if @channelship.permits?(:channelships, :write) && @fship.save
        format.html { redirect_to channel_path(@org.permalink, @channel), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @fship }
        format.js
      else
        format.html { render :new }
        format.json { render json: @fship.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def edit
    render nothing: true unless @channelship.permits?(:channelships, :write)
  end
  
  def update
    respond_to do |format|
      if @channelship.permits?(:channelships, :write) && @channel.creator != @fship.member && @fship.update!(channelship_params)
        format.html { redirect_to channel_path(@org.permalink, @channel), notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @fship }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def destroy
    @fship.destroy if @channelship.permits? :channelships, :delete
    respond_to do |format|
      format.html { redirect_to channel_path(@org.permalink, @channel), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  def accept
    @org = Organization.where(permalink: params[:permalink]).first
    @fship = @org.channelships.where(token: params[:token]).first
    @channel = @fship.channel
    
    if user_signed_in?
      @member = @org.members.where(user_id: current_user.id).first

      if @member
        if @channel.members.include? @member
          redirect_to channel_path(@fship.channel.organization.permalink, @fship.channel)
        else
          @fship.accept
          redirect_to channel_path(@fship.channel.organization.permalink, @fship.channel)
        end
      else
        @member = @org.members.create! user: current_user
        @fship.update member: @member
        @fship.accept
        redirect_to channel_path(@fship.channel.organization.permalink, @fship.channel)
      end
    else
      redirect_to new_user_registration_path(token: params[:token])
    end
  end
  
  private
  
    def set_fship
      @fship = @channel.channelships.find(params[:id])
    end
  
    def channelship_params
      params.require(:channelship).permit(:name, :email, :role, :resend)
    end
    
    def choose_layout
      action_name == "invitation" ? false : "application"
    end
end
