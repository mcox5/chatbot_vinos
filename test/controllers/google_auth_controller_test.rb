require "test_helper"

class GoogleAuthControllerTest < ActionDispatch::IntegrationTest
  test "should get callback" do
    get google_auth_callback_url
    assert_response :success
  end
end
