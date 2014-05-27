class SegmentsController < ApplicationController
  before_filter :set_organization
  before_action :set_segment, only: [:show, :edit, :update, :destroy]

  # GET /segments
  # GET /segments.json
  def index
    @segments = @org.segments
  end

  # GET /segments/1
  # GET /segments/1.json
  def show
  end

  # GET /segments/new
  def new
    @segment = Segment.new
  end

  # GET /segments/1/edit
  def edit
  end

  # POST /segments
  # POST /segments.json
  def create
    @segment = @org.segments.new(segment_params)

    respond_to do |format|
      if @segment.save
        format.html { redirect_to members_path(@org, segment_id: @segment.id), notice: 'Segment was successfully created.' }
        format.json { render :show, status: :created, location: @segment }
      else
        format.html { render :new }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /segments/1
  # PATCH/PUT /segments/1.json
  def update
    respond_to do |format|
      if @segment.update(segment_params)
        format.html { redirect_to members_path(@org, segment_id: @segment.id), notice: 'Segment was successfully updated.' }
        format.json { render :show, status: :ok, location: @segment }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @segment.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /segments/1
  # DELETE /segments/1.json
  def destroy
    @segment.destroy
    respond_to do |format|
      format.html { redirect_to segments_url, notice: 'Segment was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_segment
      @segment = @org.segments.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def segment_params
      params.require(:segment).permit(:name, :filters).tap do |whitelisted|
        if params[:segment][:filters]
          params[:segment][:filters] = params[:segment][:filters].map { |k, v| v } if params[:segment][:filters].kind_of? Hash
          whitelisted[:filters] = params[:segment][:filters]
        end
      end
    end
end
