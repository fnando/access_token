class AccessToken
  class MemcachedStore
    attr_reader :client

    def initialize(client = Dalli::Client.new)
      @client = client
    end

    def set(key, value, ttl)
      client.set(key, value)
    end

    def get(key)
      client.get(key)
    end

    def del(key)
      client.delete(key)
    end

    def key?(key)
      client.get(key) != nil
    end
  end
end
