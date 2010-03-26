require 'dm-core'

# Predefine entire namespace
module DataMapper
  module AuthenticatableResource
    module VERSION end
    module AES end
  end
end

# Extend dm-core types with an encryption class
require File.join 'dm-core', 'types', 'encryption'

# Extend dm-tyeps with encryption types
require File.join 'dm-types', 'aes'
require File.join 'dm-types', 'md5'
require File.join 'dm-types', 'sha1'
require File.join 'dm-types', 'sha2'

# The Magic
require File.join 'dm-authenticatable-resource', 'aes'
require File.join 'dm-authenticatable-resource', 'class_methods'
require File.join 'dm-authenticatable-resource', 'instance_methods'
require File.join 'dm-authenticatable-resource', 'version'