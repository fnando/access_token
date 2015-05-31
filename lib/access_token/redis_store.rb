class AccessToken
  class RedisStore
    attr_reader :client

    def initialize(client = Redis.new)
      @client = client
    end

    def set(key, value, ttl)
      client.multi do
        client.set(key, value)
        client.expire(key, ttl)
      end
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
