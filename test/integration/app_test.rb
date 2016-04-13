require "test_helper"

class AppTest < Minitest::Test
  include Rack::Test::Methods
  def app; App; end

  setup do
    User.delete_all
    User.create!(email: "john@example.com", password: "test")
  end

  test "sets bearer header" do
    post "/auth", email: "john@example.com", password: "test"
    assert last_response.headers["Bearer"]
  end

  test "updates bearer header" do
    post "/auth", email: "john@example.com", password: "test"
    bearer = last_response.headers["Bearer"]

    get "/profile", {}, "HTTP_AUTHORIZATION" => "Bearer #{bearer}"
    assert_equal 200, last_response.status
    assert bearer != last_response.headers["Bearer"]
  end

  test "rejects invalid token" do
    get "/profile", {}, "HTTP_AUTHORIZATION" => "Bearer invalid"
    assert_equal 401, last_response.status
  end

  test "rejects expired token" do
    post "/auth", email: "john@example.com", password: "test"
    bearer = last_response.headers["Bearer"]

    Time.stub :now, Time.now + 3601 do
      get "/profile", {}, "HTTP_AUTHORIZATION" => "Bearer #{bearer}"
      assert_equal 401, last_response.status
    end
  end

  test "rejects already used token" do
    post "/auth", email: "john@example.com", password: "test"
    bearer = last_response.headers["Bearer"]

    get "/profile", {}, "HTTP_AUTHORIZATION" => "Bearer #{bearer}"
    assert_equal 200, last_response.status

    get "/profile", {}, "HTTP_AUTHORIZATION" => "Bearer #{bearer}"
    assert_equal 401, last_response.status
  end
end
