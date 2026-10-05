require 'test_helper'

# End-to-end coverage of the flow the app actually exists for, driven through
# the real routing, controller stack, strong parameters and view layer rather
# than by calling the models directly. The unit tests prove each piece in
# isolation; these prove the pieces are still wired to each other.
class TaskLifecycleTest < ActionDispatch::IntegrationTest
  # Fixtures already occupy ListOne/ListTwo, and list names are unique, so use a
  # fresh name per run instead of wiping shared rows.
  def unique_list_name
    "E2E #{SecureRandom.hex(4)}"
  end

  test "create a list, add a task, complete it, then delete it" do
    # 1. Create a list through the web UI.
    assert_difference('List.count', 1) do
      post lists_path, :params => { :list => { :name => unique_list_name } }
    end
    list = List.order(:id).last
    assert_redirected_to list_tasks_path(list)

    follow_redirect!
    assert_response :success
    assert_match list.name, response.body

    # 2. Add a task to it.
    assert_difference('Task.count', 1) do
      post list_tasks_path(list), :params => { :task => { :name => "Buy milk" } }
    end
    task = list.tasks.order(:id).last
    assert_equal "Buy milk", task.name
    refute task.done?

    # 3. The task renders on the board, with its tab preselected.
    get root_path, :params => { :list_id => list.id.to_s }
    assert_response :success
    assert_match "Buy milk", response.body

    # 4. Complete it.
    put list_task_path(list, task), :params => { :task => { :done => true } }
    assert_redirected_to list_tasks_path(list)
    assert task.reload.done?

    # 5. Delete it.
    assert_difference('Task.count', -1) do
      delete list_task_path(list, task)
    end
    assert_redirected_to list_tasks_path(list)
  end

  test "an invalid task name creates nothing and reports back to the board" do
    list = List.create!(:name => unique_list_name)

    assert_no_difference('Task.count') do
      post list_tasks_path(list), :params => { :task => { :name => "" } }
    end
    assert_redirected_to list_tasks_path(list)
  end

  test "an over-long task name is rejected" do
    list = List.create!(:name => unique_list_name)
    too_long = "x" * (Task::NAME_MAX_LENGTH + 1)

    assert_no_difference('Task.count') do
      post list_tasks_path(list), :params => { :task => { :name => too_long } }
    end
    assert_redirected_to list_tasks_path(list)
  end

  test "deleting a list deletes its tasks" do
    list = List.create!(:name => unique_list_name)
    Task.create!(:name => "Doomed", :list => list)

    assert_difference(['List.count', 'Task.count'], -1) do
      delete list_path(list)
    end
    assert_equal 0, Task.where(:list_id => list.id).count
  end

  test "a task cannot be destroyed through a list it does not belong to" do
    list = List.create!(:name => unique_list_name)
    other = List.create!(:name => unique_list_name)
    task = Task.create!(:name => "Protected", :list => list)

    assert_no_difference('Task.count') do
      delete list_task_path(other, task)
    end
    assert Task.exists?(task.id)
  end
end