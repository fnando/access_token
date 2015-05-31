class AccessToken
  class NullStore
    def set(key, value, ttl)
      true
    end

    def get(key)
      true
    end

    def del(key)
      true
    end

    def key?(key)
      true
    end
  end
end
