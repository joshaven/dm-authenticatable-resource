require 'rubygems'
require 'spec'
require 'dm-migrations'
DataMapper.setup(:default, 'sqlite3::memory:')

require File.join File.dirname(__FILE__), '..', 'lib', 'dm-authenticatable-resource'

DataMapper.setup(:default, 'sqlite3::memory:')
