class OrganizationsController < ApplicationController  
  layout :choose_layout
  before_filter :redirect_to_root, if: -> { !current_user.admin? }, only: [:index, :edit, :update]
  before_filter :set_organization, if: -> { action_name == "example" }
  
  def index
    @organizations = Organization.all
  end
  
  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.modules = @website["modules"]

    respond_to do |format|
      if @organization.save
        @organization.users.push current_user
        format.html { redirect_to root_path, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit
    @organization = Organization.where(permalink: params[:id]).first
  end
  
  def update
    @organization = Organization.where(permalink: params[:id]).first
    
    if params[:toggle_module]
      if @organization.modules.include? params[:toggle_module]
        @organization.modules.delete params[:toggle_module]
      else
        modules = @organization.modules + [params[:toggle_module]]
        @organization.modules = modules
      end
    else
      @organization.assign_attributes(organization_params)
    end
    
    respond_to do |format|
      if @organization.save
        format.html { redirect_to organizations_path, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end
  
  def example
    render "organizations/examples/#{params[:example].to_s.gsub("contact", "member")}"
  end

  private
    def organization_params
      if current_user.admin?
        params.require(:organization).permit(:name, :permalink, :website, :logo, modules: [])
      else
        params.require(:organization).permit(:name, :permalink, :website, :logo)
      end
    end
    
    def choose_layout
      action_name == "example" ? false : "application"
    end
end
