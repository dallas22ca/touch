class OrganizationsController < ApplicationController  
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

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def organization_params
      params.require(:organization).permit(:name, :permalink, :website, :logo)
    end
end
