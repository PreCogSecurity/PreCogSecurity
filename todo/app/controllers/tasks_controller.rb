class TasksController < ApplicationController
  # Upper bound on the number of tasks serialised by the JSON index.
  #
  # The JSON representation used to run `Task.all.as_json`, which serialised
  # the entire tasks table on every request: a full-table disclosure and an
  # unbounded memory/CPU cost, both reachable by an unauthenticated caller.
  # Clients that need bulk data should page explicitly via `limit`/`offset`.
  MAX_JSON_TASKS = 200

  def index
    @task   = Task.new
    @lists  = List.all
    @list   = List.new
    # Resolve the requested tab here rather than in the view: the view used to
    # run its own query against a raw params value on every render.
    @selected_list = selected_list

    respond_to do |format|
      format.html
      format.json do
        # as_json (not to_json) so the payload is not double-encoded.
        render :json => { :tasks => json_tasks.as_json }
      end
    end
  end

  def create
    @list = parent_list
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
    @list = parent_list
    @task = @list.tasks.find(numeric_id!(:id))

    respond_to do |format|
      if @task.update(task_attributes)
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
    @list = parent_list
    # Scope the lookup to the list so a task cannot be deleted through a
    # mismatched list id.
    @task = @list.tasks.find(numeric_id!(:id))
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(list_tasks_url(@list)) }
      format.json { render :json => { :status => 'success' } }
    end
  end

  private

  # The list named in the nested route, with its id validated first.
  def parent_list
    List.find(numeric_id!(:list_id))
  end

  # The list whose tab should be preselected, or nil when no valid id was given.
  def selected_list
    return nil unless params[:list_id].to_s =~ NUMERIC_ID_FORMAT

    # An id that matches no row simply yields nil, which the view treats as
    # "no tab preselected".
    List.find_by(:id => params[:list_id].to_s.to_i)
  end

  # Bounded, list-scoped feed for JSON clients.
  def json_tasks
    scope = @selected_list ? @selected_list.tasks : Task.all
    scope.order(:id).limit(MAX_JSON_TASKS)
  end

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
    # SECURITY: :list_id is deliberately NOT permitted here.
    #
    # Task ownership is derived from the nested route's parent list, and
    # create/update/destroy all enforce that scope. Allowing list_id through
    # strong parameters let any caller re-parent a task into an arbitrary list
    # -- the one write path that could move data across the boundary the rest of
    # the controller enforces -- bypassing the list scoping entirely.
    params.require(:task).permit(:name, :done)
  end
end