class TasksController < ApplicationController
  before_action :set_organization
  before_action :set_folder
  before_action :set_permissions
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_filter :redirect_to_folder, unless: Proc.new { @foldership.permits? controller_name, action_type }

  # GET /tasks
  # GET /tasks.json
  def index
    @does_have_sidebar = true
    @tasks = @folder.tasks.includes(:creator) if @foldership.permits?(:tasks, :read)
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
    @task = @folder.tasks.new(task_params)
    @task.creator = @member

    respond_to do |format|
      if @foldership.permits?(:tasks, :write) && @task.save
        format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully created.' }
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
      if @foldership.permits?(:tasks, :write) && @task.update(task_params)
        format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully updated.' }
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
    @task.destroy if @foldership.permits? :tasks, :delete
    respond_to do |format|
      format.html { redirect_to folder_path(@org, @folder), notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end
  
  def sort
    params[:task].each_with_index do |id, index|
      @folder.tasks.find(id).update ordinal: index + 1, skip_jibe: true
    end
    render nothing: true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = @folder.tasks.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:content, :complete)
    end
end
