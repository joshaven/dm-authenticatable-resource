require 'rubygems'
require 'spec'
require File.join File.dirname(__FILE__), '..', 'lib', 'dm-authenticatable-resource'

DataMapper.setup(:default, 'sqlite3::memory:')
