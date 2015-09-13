class AccessToken
  class RedisStore
    attr_reader :client

    def initialize(client = Redis.new)
      @client = client
    end

    def set(key, value, ttl)
      client.setex(key, ttl, value)
    end

    def get(key)
      client.get(key)
    end

    def del(key)
      client.del(key)
    end

    def key?(key)
      client.exists(key)
    end
  end
end
