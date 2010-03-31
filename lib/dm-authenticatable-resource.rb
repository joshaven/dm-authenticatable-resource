require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'digest'

# Predefine entire namespace
module DataMapper
  module AuthenticatableResource
    module ClassMethods end
    module InstanceMethods end
    module VERSION end
    module AES end
  end
end

def require_file(*args)
  require File.expand_path(File.join(File.dirname(__FILE__), *args))
end


# Extend dm-core types with an encryption class
require_file 'dm-core', 'types', 'encryption'

# Extend dm-tyeps with encryption types
require_file 'dm-types', 'aes'
require_file 'dm-types', 'md5'
require_file 'dm-types', 'sha1'
require_file 'dm-types', 'sha2'

# The good stuff
require_file 'dm-authenticatable-resource', 'aes'
require_file 'dm-authenticatable-resource', 'authenticatable_resource'
require_file 'dm-authenticatable-resource', 'version'
