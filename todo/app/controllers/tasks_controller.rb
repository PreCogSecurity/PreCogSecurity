class TasksController < ApplicationController
  def index
    @todo   = Task.where(:done => false)
    @task   = Task.new
    @lists  = List.all
    @list   = List.new

    respond_to do |format|
      format.html
      format.json do
        # as_json (not to_json) so the payload is not double-encoded.
        render :json => { :tasks => Task.all.as_json }
      end
    end
  end

  def create
    @list = List.find(params[:list_id])
    @task = @list.tasks.new(task_params)

    if @task.save
      status = "success"
      flash[:notice] = "Your task was created."
    else
      status = "failure"
      flash[:alert] = "There was an error creating your task."
    end
    respond_to do |format|
      format.html do
        redirect_to(list_tasks_url(@list))
      end
      format.json do
        if status == "success"
          render :json => { :status => status, :task => @task.as_json }
        else
          render :json => { :status => status, :errors => @task.errors.full_messages }, :status => :unprocessable_entity
        end
      end
    end
  end

  def update
    @list = List.find(params[:list_id])
    @task = @list.tasks.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(task_attributes)
        format.html { redirect_to(list_tasks_url(@list), :notice => 'Task was successfully updated.') }
        format.json { render :json => { :status => 'success', :task => @task.as_json } }
      else
        # The routes intentionally expose no edit view; surface the failure
        # instead of rendering a template that does not exist.
        format.html { redirect_to(list_tasks_url(@list), :alert => 'There was an error updating your task.') }
        format.json { render :json => { :status => 'failure', :errors => @task.errors.full_messages }, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @list = List.find(params[:list_id])
    # Scope the lookup to the list so a task cannot be deleted through a
    # mismatched list id.
    @task = @list.tasks.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(list_tasks_url(@list)) }
      format.json { render :json => { :status => 'success' } }
    end
  end

  private

  def task_params
    raw = params[:task]
    raw = JSON.parse(raw) if raw.is_a?(String)
    unless raw.is_a?(Hash)
      raise ActionController::BadRequest, 'task parameters must be an object'
    end
    ActionController::Parameters.new(raw).permit(:name)
  rescue JSON::ParserError
    raise ActionController::BadRequest, 'task parameters contain invalid JSON'
  end

  def task_attributes
    params.require(:task).permit(:name, :done, :list_id)
  end
end