require 'test_helper'

class NullStoreTest < Minitest::Test
  def store; @store ||= AccessToken::NullStore.new; end

  test 'implements set' do
    assert store.set('key', 'value', 3600)
  end

  test 'implements get' do
    assert store.get('key')
  end

  test 'implements del' do
    assert store.del('key')
  end

  test 'implements key?' do
    assert store.key?('key')
  end
end
