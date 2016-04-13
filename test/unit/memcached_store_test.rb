require "test_helper"

class MemcachedStoreTest < Minitest::Test
  def store; @store ||= AccessToken::MemcachedStore.new; end

  test "sets value with expiry" do
    store.set("key", "value", 3600)

    assert_equal store.get("key"), "value"
  end

  test "deletes value" do
    store.set("key", "value", 3600)
    assert store.key?("key")

    store.del("key")
    refute store.key?("key")
  end
end
