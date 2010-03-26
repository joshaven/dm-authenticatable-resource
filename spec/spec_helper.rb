require 'rubygems'
require 'flexmock'
require File.join File.dirname(__FILE__), '..', 'lib', 'dm-authenticatable-resource'

DataMapper.setup(:default, 'sqlite3::memory:')

# Configure RSpec to use the Flex Mock mocking framework
Spec::Runner.configure do |config|
  config.mock_with :flexmock
end