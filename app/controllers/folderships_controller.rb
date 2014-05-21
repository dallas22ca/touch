class FoldershipsController < ApplicationController
  layout :choose_layout
  before_action :set_organization, except: [:accept]
  before_action :set_folder_with_permissions, except: [:accept]
  before_action :set_fship, only: [:show, :edit, :update, :destroy]
  before_filter :redirect_to_folder, unless: Proc.new { @foldership.permits? controller_name, action_type }, only: [:index]
  
  def index
    @folderships = @member.folderships.unaccepted
  end
  
  def new
    @fship = Foldership.new
    render nothing: true unless @foldership.permits?(:folderships, :write)
  end
  
  def create
    @fship = @folder.folderships.new(foldership_params)
    @fship.creator = @member

    respond_to do |format|
      if @foldership.permits?(:folderships, :write) && @fship.save
        format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully created.' }
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
    render nothing: true unless @foldership.permits?(:folderships, :write)
  end
  
  def update
    respond_to do |format|
      if @foldership.permits?(:folderships, :write) && @folder.creator != @fship.member && @fship.update!(foldership_params)
        format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully updated.' }
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
    @fship.destroy if @foldership.permits? :folderships, :delete
    respond_to do |format|
      format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  def accept
    @org = Organization.where(permalink: params[:permalink]).first
    @foldership = params[:token] ? @org.folderships.where(token: params[:token]).first : @org.folderships.find(params[:foldership_id])
    @folder = @foldership.folder
    
    if user_signed_in?
      @member = @org.members.where(user_id: current_user.id).first

      if @member
        if @folder.members.accepted.include? @member
          redirect_to folder_path(@foldership.folder.organization, @foldership.folder)
        else
          @foldership.accept
          redirect_to folder_path(@foldership.folder.organization, @foldership.folder)
        end
      else
        @member = @org.members.create! user: current_user
        @foldership.update member: @member
        @foldership.accept
        redirect_to folder_path(@foldership.folder.organization, @foldership.folder)
      end
    else
      redirect_to new_user_registration_path(token: params[:token])
    end
  end
  
  private
  
    def set_fship
      @fship = @folder.folderships.find(params[:id])
    end
  
    def foldership_params
      params.require(:foldership).permit(:name, :email, :preset, :resend)
    end
    
    def choose_layout
      action_name == "invitation" ? false : "application"
    end
end
