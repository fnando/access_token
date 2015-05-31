class AccessToken
  require 'parsel'

  require 'access_token/version'
  require 'access_token/redis_store'
  require 'access_token/memcached_store'
  require 'access_token/null_store'

  BEARER_HEADER        = 'Bearer'.freeze
  EXPIRES_HEADER       = 'Expires'.freeze
  AUTHORIZATION_HEADER = 'HTTP_AUTHORIZATION'.freeze
  TIME_KEY             = 'time'.freeze
  ID_KEY               = 'id'.freeze
  SIGNATURE_KEY        = 'signature'.freeze
  BEARER_REGEX         = /\ABearer (.*?)\z/

  # Set the HTTP request object.
  # It must implement the `ip` and `user_agent` methods.
  attr_reader :request

  # Set the HTTP response object.
  # It must implement the `headers` method.
  attr_reader :response

  # Set the token store strategy.
  # By default it uses in-memory store.
  attr_reader :store

  # Set the token encryptor strategy.
  # By default it uses the Parsel::JSON encryptor.
  attr_reader :encryptor

  # Set the token TTL.
  # Defaults to 86400 (24 hours).
  attr_reader :ttl

  # Set the encryption secret.
  attr_reader :secret

  def initialize(request:, response:, secret:, ttl: 3600, store: NullStore.new, encryptor: Parsel::JSON)
    @request = request
    @response = response
    @store = store
    @secret = secret
    @ttl = ttl
    @encryptor = encryptor
  end

  def request_signature
    @request_signature ||= Digest::SHA1.hexdigest("#{request.ip}#{request.user_agent}")
  end

  def update(record)
    now = Time.now
    timestamp = now.to_i
    data = {TIME_KEY => timestamp, SIGNATURE_KEY => request_signature, ID_KEY => record.id}
    token = encryptor.encrypt(secret, data)
    store.set(token, timestamp, ttl)
    response[BEARER_HEADER] = token
    response[EXPIRES_HEADER] = (Time.now + ttl).httpdate
    token
  end

  def resolve(token = bearer)
    return unless store.key?(token)

    data = encryptor.decrypt(secret, token)
    store.del(token)

    return unless data
    return unless fresh?(data[TIME_KEY])
    return unless request_signature == data[SIGNATURE_KEY]

    data[ID_KEY]
  end

  def bearer
    request.env[AUTHORIZATION_HEADER].to_s[BEARER_REGEX, 1]
  end

  def fresh?(timestamp)
    timestamp > Time.now.to_i - ttl
  end
end
