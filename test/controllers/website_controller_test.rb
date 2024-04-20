require "test_helper"

class WebsiteControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get website_new_url
    assert_response :success
  end
end
