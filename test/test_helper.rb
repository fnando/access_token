$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'access_token'
require 'minitest/utils'
require 'minitest/autorun'
require 'rack/test'

require 'redis'
require 'dalli'

FileList['./test/support/**/*.rb'].each do |file|
  require file
end
