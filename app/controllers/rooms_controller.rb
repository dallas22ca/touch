class RoomsController < ApplicationController
  before_filter :set_organization
  before_action :set_room, only: [:show, :edit, :update, :destroy]

  # GET /rooms
  # GET /rooms.json
  def index
    @rooms = @org.rooms
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @memberships = @org.memberships.last_name_asc
    @meetings = Meeting
    @meetings = @meetings.where(room_id: @room.id)
    @last_meeting = @meetings.date_desc.first
    @first_meeting = @meetings.date_asc.first
    @meetings = @meetings.where("date < ?", Time.at(params[:finish].to_i)) if params[:finish]
    @meetings = @meetings.where("date > ?", Time.at(params[:start].to_i)).date_asc if params[:start]
    @meetings = @meetings.date_desc.limit(5).reverse
    
    @meeting_events = {}
    @meetings.each do |meeting|
      @meeting_events[meeting.id] = meeting.events true
    end
    
    @nils = 5 - @meetings.count
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = @org.rooms.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to room_path(@org.permalink, @room), notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to room_path(@org.permalink, @room), notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_path(@org.permalink), notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = @org.rooms.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:name)
    end
end
