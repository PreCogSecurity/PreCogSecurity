require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  setup do
    @list = lists(:one)
    @task = tasks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lists)
  end

  test "should get index as json without double-encoding" do
    get :index, :format => :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_kind_of Array, body["tasks"]
    assert body["tasks"].all? { |t| t.is_a?(Hash) }
  end

  test "should create task" do
    assert_difference('Task.count') do
      post :create, :task => @task.attributes, :list_id => @list.id
    end

    assert_redirected_to list_tasks_path(@list)
  end

  test "should create task using json" do
    assert_difference('Task.count') do
      post :create, :task => @task.attributes, :list_id => @list.id, :format => :json
    end

    assert_response :success
  end

  test "should create task from a json string body" do
    assert_difference('Task.count') do
      post :create, :task => { :name => "From JSON string" }.to_json, :list_id => @list.id, :format => :json
    end

    assert_response :success
  end

  test "should reject malformed json task parameters" do
    assert_no_difference('Task.count') do
      post :create, :task => "{not valid json", :list_id => @list.id, :format => :json
    end

    assert_response :bad_request
  end

  test "should reject non-hash task parameters" do
    assert_no_difference('Task.count') do
      post :create, :task => ["not", "a", "hash"], :list_id => @list.id, :format => :json
    end

    assert_response :bad_request
  end

  test "should update task" do
    put :update, :id => @task.to_param, :task => @task.attributes, :list_id => @list.id
    assert_redirected_to list_tasks_path(@list)
  end

  test "should redirect to the list when a task update fails validation" do
    put :update, :id => @task.to_param, :task => { :name => "" }, :list_id => @list.id
    assert_redirected_to list_tasks_path(@list)
  end

  test "should not update a task through a mismatched list" do
    put :update, :id => @task.to_param, :task => { :name => "Hijacked" }, :list_id => lists(:two).id
    assert_redirected_to root_path
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete :destroy, :id => @task.to_param, :list_id => @list.id
    end

    assert_redirected_to list_tasks_path(@list)
  end

  test "should not destroy a task through a mismatched list" do
    assert_no_difference('Task.count') do
      delete :destroy, :id => @task.to_param, :list_id => lists(:two).id
    end

    assert_redirected_to root_path
  end
end