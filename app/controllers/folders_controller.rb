class ChannelsController < ApplicationController
  before_filter :set_organization
  before_action :set_channel_with_permissions, only: [:show, :edit, :update, :destroy]
  before_filter :send_to_channel, unless: Proc.new { @channelship.permits? :channels, :write }, only: [:edit, :update, :destroy]

  # GET /channels
  # GET /channels.json
  def index
    @channels = @member.channels
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = @member.channels.new(channel_params)
    @channel.creator = @member
    @channel.organization = @org

    respond_to do |format|
      if @channel.save
        format.html { redirect_to channel_path(@org.permalink, @channel), notice: 'Channel was successfully created.' }
        format.json { render :show, status: :created, location: @channel }
        format.js
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to channel_path(@org.permalink, @channel), notice: 'Channel was successfully updated.' }
        format.json { render :show, status: :ok, location: @channel }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url(@org.permalink), notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = @member.channels.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      params.require(:channel).permit(:name, :archived, :seed)
    end
end
