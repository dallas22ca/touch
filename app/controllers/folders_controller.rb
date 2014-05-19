class FoldersController < ApplicationController
  before_filter :set_organization
  before_action :set_folder_with_permissions, only: [:show, :edit, :update, :destroy]
  before_filter :send_to_folder, unless: Proc.new { @foldership.permits? :folders, :write }, only: [:edit, :update, :destroy]

  # GET /folders
  # GET /folders.json
  def index
    @folders = @member.folders
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
    redirect_to folder_comments_path(@org.permalink, @folder)
  end

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # GET /folders/1/edit
  def edit
  end

  # POST /folders
  # POST /folders.json
  def create
    @folder = @member.folders.new(folder_params)
    @folder.creator = @member
    @folder.organization = @org

    respond_to do |format|
      if @folder.save
        format.html { redirect_to folder_path(@org.permalink, @folder), notice: 'Folder was successfully created.' }
        format.json { render :show, status: :created, location: @folder }
        format.js
      else
        format.html { render :new }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /folders/1
  # PATCH/PUT /folders/1.json
  def update
    respond_to do |format|
      if @folder.update(folder_params)
        format.html { redirect_to folder_path(@org.permalink, @folder), notice: 'Folder was successfully updated.' }
        format.json { render :show, status: :ok, location: @folder }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @folder.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /folders/1
  # DELETE /folders/1.json
  def destroy
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to folders_url(@org.permalink), notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder
      @folder = @member.folders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params.require(:folder).permit(:name, :archived, :seed)
    end
end
