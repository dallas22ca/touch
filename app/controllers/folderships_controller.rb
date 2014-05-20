class FoldershipsController < ApplicationController
  layout :choose_layout
  before_action :set_organization, except: [:accept]
  before_action :set_folder_with_permissions
  before_action :set_fship, only: [:show, :edit, :update, :destroy]
  
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
    @fship = @org.folderships.where(token: params[:token]).first
    @folder = @fship.folder
    
    if user_signed_in?
      @member = @org.members.where(user_id: current_user.id).first

      if @member
        if @folder.members.include? @member
          redirect_to folder_path(@fship.folder.organization, @fship.folder)
        else
          @fship.accept
          redirect_to folder_path(@fship.folder.organization, @fship.folder)
        end
      else
        @member = @org.members.create! user: current_user
        @fship.update member: @member
        @fship.accept
        redirect_to folder_path(@fship.folder.organization, @fship.folder)
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
      params.require(:foldership).permit(:name, :email, :role, :resend)
    end
    
    def choose_layout
      action_name == "invitation" ? false : "application"
    end
end
