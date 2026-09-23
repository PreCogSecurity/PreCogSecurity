require 'test_helper'

class HealthControllerTest < ActionController::TestCase
  test "health returns ok when the database is reachable" do
    get :show, :format => :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal "ok", body["status"]
    assert_equal true, body["database"]
    assert body["time"].present?
  end
end