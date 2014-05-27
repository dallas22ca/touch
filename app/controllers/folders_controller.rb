class FoldersController < ApplicationController
  before_filter :set_organization
  before_action :set_folder
  before_action :set_permissions
  before_filter :redirect_to_root, unless: Proc.new { @member.permits? :folders, action_type }
  before_filter :redirect_to_root, unless: Proc.new { @foldership.permits? :folders, action_type }, only: [:edit, :update, :destroy]

  # GET /folders
  # GET /folders.json
  def index
    @folders = @member.folders.accepted
    redirect_to folder_path(@org, @folders.first) if @folders.count == 1
  end

  # GET /folders/1
  # GET /folders/1.json
  def show
    %w[comments tasks homes documents folderships].each do |controller|
      if @foldership.permits? controller, :read
        redirect_to polymorphic_path([@folder, controller.to_sym], permalink: @org.permalink)
        break
      end
    end
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
        format.html { redirect_to folder_path(@org, @folder), notice: 'Folder was successfully created.' }
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
        format.html { redirect_to folder_path(@org, @folder), notice: 'Folder was successfully updated.' }
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
      format.html { redirect_to folders_url(@org), notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def reset
    if @folder.destroy
      @org.seed_first_folder
    end

    respond_to do |format|
      format.html { redirect_to folders_url(@org), notice: 'Folder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def folder_params
      params.require(:folder).permit(:name, :archived, :seed)
    end
end
