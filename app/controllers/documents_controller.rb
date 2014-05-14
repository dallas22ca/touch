class DocumentsController < ApplicationController
  before_action :set_organization
  before_action :set_folder_with_permissions
  before_action :set_document, only: [:show, :edit, :update, :destroy, :download]

  # GET /documents
  # GET /documents.json
  def index
    @documents = @folder.documents if @foldership.permits?(:documents, :read)
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = @folder.documents.new(document_params)
    @document.creator = current_user

    respond_to do |format|
      if @foldership.permits?(:documents, :write) && @document.save!
        format.html { redirect_to folder_path(@org.permalink, @folder), notice: 'Document was successfully created.' }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update
    respond_to do |format|
      if @foldership.permits?(:documents, :write) && @document.update(document_params)
        format.html { redirect_to folder_path(@org.permalink, @folder), notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy if @foldership.permits? :documents, :delete
    respond_to do |format|
      format.html { redirect_to folder_path(@org.permalink, @folder), notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  def download
    redirect_to @document.file.expiring_url(5)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      if params[:document_id]
        @document = @folder.documents.find(params[:document_id])
      else
        @document = @folder.documents.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(:file)
    end
end
