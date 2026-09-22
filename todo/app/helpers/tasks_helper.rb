module TasksHelper
  # Human-readable status for a task.
  def task_status(task)
    task.done? ? "Done" : "Pending"
  end
end