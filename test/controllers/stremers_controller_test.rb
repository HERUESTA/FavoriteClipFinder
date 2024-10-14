require "test_helper"

class StreamersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get streamers_show_url
    assert_response :success
  end
end
