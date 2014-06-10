class SequencesController < ApplicationController
  before_filter :set_organization
  before_action :set_sequence, only: [:show, :edit, :update, :destroy]

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences = @org.sequences
  end

  # GET /sequences/1
  # GET /sequences/1.json
  def show
  end

  # GET /sequences/new
  def new
    @sequence = Sequence.new
  end

  # GET /sequences/1/edit
  def edit
  end

  # POST /sequences
  # POST /sequences.json
  def create
    @sequence = @org.sequences.new(sequence_params)
    @sequence.creator = @member
    apply_defaults

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to sequences_path(@org), notice: 'Sequence was successfully created.' }
        format.json { render :show, status: :created, location: @sequence }
      else
        format.html { render :new }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sequences/1
  # PATCH/PUT /sequences/1.json
  def update
    @sequence.assign_attributes sequence_params
    apply_defaults
    
    respond_to do |format|
      if @sequence.save
        format.html { redirect_to sequences_path(@org), notice: 'Sequence was successfully updated.' }
        format.json { render :show, status: :ok, location: @sequence }
      else
        format.html { render :edit }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sequences/1
  # DELETE /sequences/1.json
  def destroy
    @sequence.destroy
    respond_to do |format|
      format.html { redirect_to sequences_path(@org), notice: 'Sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def bulk_add
    if params[:sequence_id]
      @sequence = @org.sequences.find(params[:sequence_id])
      @sequence.add_tasks_for params[:member_ids]
      render "update"
    end
  end
  
  def bulk_remove
    if params[:sequence_id]
      @sequence = @org.sequences.find(params[:sequence_id])
      @sequence.remove_tasks_for params[:member_ids]
      render "update"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sequence
      @sequence = @org.sequences.find(params[:id])
    end
    
    def apply_defaults
      @sequence.steps.each do |step|
        if step.task.message
          step.task.message.creator = @member
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sequence_params
      params.require(:sequence).permit(:strategy, :interval, :date, steps_attributes: [:id, :action, :offset, task_attributes: [:id, :content, :template, message_attributes: [:id, :subject, :body, :template]]])
    end
end
