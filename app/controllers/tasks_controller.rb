class TasksController < ApplicationController
  before_action :set_organization
  before_action :set_permissions
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  # GET /tasks
  # GET /tasks.json
  def index
    @date = params[:date] ? Time.parse(params[:date]).in_time_zone : Time.zone.now
    @start = @date.beginning_of_day.in_time_zone
    @finish = @date.end_of_day.in_time_zone
    @tense = determine_tense @date
    @day_name = @start == @now.beginning_of_day ? "Today" : @start.strftime("%a, %b %-d")
    
    @tasks = case @tense
    when "past"
      @member.tasks.where("(complete = :false and due_at >= :start and due_at <= :finish) or (complete = :true and completed_at >= :start and completed_at <= :finish)", 
        true: true,
        false: false,
        nil: nil,
        start: @start,
        finish: @finish
      )
    when "present", "future"
      @member.tasks.where("(due_at is :nil and complete = :false) or (complete = :false and due_at is not :nil and due_at >= :start and due_at <= :finish) or (complete = :true and completed_at is not :nil and completed_at >= :start and completed_at <= :finish)",
        true: true,
        false: false,
        nil: nil,
        start: @start,
        finish: @finish
      )
    end
    
    @incomplete = @member.tasks.where("due_at < ?", @start).incomplete.by_ordinal.order(:due_at).group_by{ |t| p t.due_at.to_date }
    @complete = @tasks.complete.by_completed_at
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = @member.tasks.new(task_params)
    @task.creator = @member
    @task.due_at ||= Time.zone.now

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path(@org), notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
        format.js
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to tasks_path(@org), notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  def sort
    params[:task].each_with_index do |id, index|
      @member.tasks.find(id).update ordinal: index + 1, skip_jibe: true
    end
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = @member.tasks.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:content, :complete, :due_at)
    end
    
    def determine_tense(date)
      @now = Time.zone.now
      
      if date.beginning_of_day < @now.beginning_of_day
        "past"
      elsif date.end_of_day > @now.end_of_day
        "future"
      else
        "present"
      end
    end
end
