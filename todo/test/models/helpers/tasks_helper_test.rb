require 'test_helper'

class TasksHelperTest < ActionView::TestCase
  test "task_status returns Done for completed tasks" do
    task = tasks(:one)
    task.update_column(:done, true)
    assert_equal "Done", task_status(task)
  end

  test "task_status returns Pending for open tasks" do
    assert_equal "Pending", task_status(tasks(:one))
  end
end