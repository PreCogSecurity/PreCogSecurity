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

  # --- input validation on list_id ------------------------------------------

  test "should select the requested list tab" do
    get :index, :list_id => lists(:two).id.to_s
    assert_response :success
    assert_equal lists(:two), assigns(:selected_list)
  end

  test "should ignore a malformed list_id instead of passing it to the adapter" do
    get :index, :list_id => "1 OR 1=1"
    assert_response :success
    assert_nil assigns(:selected_list)
  end

  test "should ignore a non-numeric list_id" do
    get :index, :list_id => "not-a-number"
    assert_response :success
    assert_nil assigns(:selected_list)
  end

  test "should ignore an unknown list_id" do
    get :index, :list_id => "999999"
    assert_response :success
    assert_nil assigns(:selected_list)
  end

  test "should reject a malformed list_id on create with 400" do
    assert_no_difference('Task.count') do
      post :create, :task => { :name => "Nope" }, :list_id => "abc", :format => :json
    end
    assert_response :bad_request
  end

  test "should reject a malformed list_id on update with 400" do
    put :update, :id => @task.to_param, :task => { :name => "Nope" },
                   :list_id => "1 OR 1=1", :format => :json
    assert_response :bad_request
    assert_equal tasks(:one).name, @task.reload.name
  end

  test "should reject a malformed list_id on destroy with 400" do
    assert_no_difference('Task.count') do
      delete :destroy, :id => @task.to_param, :list_id => "abc", :format => :json
    end
    assert_response :bad_request
  end

  test "should reject a malformed task id with 400" do
    assert_no_difference('Task.count') do
      delete :destroy, :id => "abc", :list_id => @list.id, :format => :json
    end
    assert_response :bad_request
  end

  test "should reject a malformed task id on update with 400" do
    put :update, :id => "abc", :task => { :name => "Nope" },
                   :list_id => @list.id, :format => :json
    assert_response :bad_request
  end

  test "should not emit a selected tab option when no list was requested" do
    get :index
    assert_response :success
    refute_includes response.body, "opts.selected ="
  end

  test "should emit an integer selected tab option for a valid list_id" do
    get :index, :list_id => lists(:two).id.to_s
    assert_response :success
    assert_match(/opts\.selected = \d+;/, response.body)
  end

  # --- mass assignment / authorization --------------------------------------

  test "should not allow a task to be re-parented through list_id" do
    original_list_id = @task.list_id

    put :update, :id => @task.to_param, :list_id => @list.id,
                    :task => { :name => "Renamed", :list_id => lists(:two).id }

    assert_redirected_to list_tasks_path(@list)
    @task.reload
    assert_equal "Renamed", @task.name
    assert_equal original_list_id, @task.list_id,
                 "list_id must not be assignable through strong parameters"
  end

  test "should ignore an unpermitted attribute on create" do
    assert_difference('Task.count') do
      post :create, :task => { :name => "Scoped", :list_id => lists(:two).id },
                     :list_id => @list.id
    end

    created = Task.order(:id).last
    assert_equal @list.id, created.list_id
  end

  # --- bounded json feed ----------------------------------------------------

  test "should cap the json index at MAX_JSON_TASKS" do
    Task.delete_all
    (TasksController::MAX_JSON_TASKS + 5).times do |i|
      Task.create!(:name => "Task #{i}", :list => @list)
    end

    get :index, :format => :json
    assert_response :success
    assert_equal TasksController::MAX_JSON_TASKS, JSON.parse(response.body)["tasks"].length
  end

  test "should scope the json index to the requested list" do
    Task.delete_all
    Task.create!(:name => "In list two", :list => lists(:two))

    get :index, :list_id => lists(:two).id.to_s, :format => :json
    assert_response :success

    tasks = JSON.parse(response.body)["tasks"]
    assert tasks.any?, "expected the scoped feed to return the list's tasks"
    assert tasks.all? { |t| t["list_id"] == lists(:two).id },
           "scoped feed must not leak tasks from other lists"
  end
end