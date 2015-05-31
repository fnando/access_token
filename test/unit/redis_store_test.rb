require 'test_helper'

class RedisStoreTest < Minitest::Test
  def store; @store ||= AccessToken::RedisStore.new; end

  test 'sets value with expiry' do
    store.set('key', 'value', 3600)

    assert_equal store.get('key'), 'value'
    assert_equal 3600, store.client.ttl('key')
  end

  test 'deletes value' do
    store.set('key', 'value', 3600)
    assert store.key?('key')

    store.del('key')
    refute store.key?('key')
  end
end
