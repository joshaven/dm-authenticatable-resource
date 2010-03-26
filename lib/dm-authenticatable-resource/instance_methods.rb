# require 'digest'
# require File.expand_path(File.join(File.dirname(__FILE__),'aes'))
# 
# module DataMapper
#   module AuthenticatableResource
#     # An authenticatable object.  This object never keeps the plain text password for any given time nor stores enough information to 
#     # decrypt reversable passwords unless the encryption is set to AES-128 AES-192 or AES-256 which are spicifically for reversable.
#     # encryption
#     # 
#     # In the case of irreversible password encryptiong, the crypted_password is plain text password encrypted with the specified
#     # encryption method.  In the case of the reversable encryption methods, crypted_password is encrypted with
#     # the encryption key: self.auth_method which is either set manually or through config/password_encryption.yml
#     # 
#     # The supported encryption methods are: MD5, SHA1, SHA2, AES-128, AES-192 & AES-256.  MD5 and SHA are one way (irreversible) 
#     # encryption methods whereas AES can be encrypted and decrypted (reversable).  AES requires an environment variable.
#     #
#     # Prerequisites:
#     #
#     #   An encryption salt and adapter must be set
#     #
#     # Example:
#     #   class User
#     #     include DataMapper::AuthenticatableResource
#     #     property :id, Serial
#     #     property :login,            String, :lazy => false, :required => true
#     #     property :crypted_password, SHA2,   :lazy => false, :required => true, :length => 64
#     #   end
#     #     
#     #
#     #   p = User.new({:login=>'user@example.com', :password => 'Pa55word', :password_confirmation => 'Pa55word'})
#     #   => #<User @id=nil @login="user@example.com" @crypted_password="8e23dd899cb43892712d93f5c4446754a7c1a9387cd2d4ab82df5e195166b6e5">
#     module Passwords #:nodoc:
#       class AES #:nodoc:
#         extend DataMapper::AuthenticatableResource::AES
#       end
# 
#       module ClassEval #:nodoc:
#         def password_requirements(&block) #:nodoc:
#           self.send(:define_method, :is_valid_password?, block)
#         end
#         
#         # Set the 
#         def aes_key(key=nil)
#           key.nil? ? @aes_key : @aes_key = key
#         end
#         def aes_key=(key)
#           @aes_key=key
#         end
# 
#         # Class method that authenticates against an AuthenticatableResource instance found from the data store. 
#         # Returns the AuthenticatableResource object or false.  This method is basically find_and_return_if_authenticated_with?
#         #
#         # Example (given that User includes DataMapper::AuthenticatableResource):
#         #   User.authenticate 'joe@user.com', 'Pa55word'
#         #   => #<User @id=1 @name="Joe User" @login="joe@user.com" @crypted_password="f23c9a5dca7aef19a3db264c5c21a2f8">
#         #   User.authenticate 'joe@user.com', 'BadPa55word'
#         #   => false
#         def authenticate(login, pass)
#           user = User.first(props[:login] => login) || User.new
#           user.authenticates_with?(login, pass) ? user : false
#         end
# 
#         # Class Method to set custom methods for :login or :crypted_password.  
#         #
#         # For example
#         #   class User
#         #     include DataMapper::AuthenticatableResource
#         #     property :id, Serial
#         #     property :email,      String
#         #     property :password,   SHA2
#         #     self.authentication_properties {:login => 'email', :crypted_password => 'password'}
#         #   end
#         
#         def authentication_properties(props = {})
#           @authentication_properties ||= {:login => :login, :crypted_password => :crypted_password}
#           @authentication_properties.merge!( props.reject {|k,v| k unless k == :login || k == :crypted_password} )
#         end
#       end
# 
#       def self.included(base) #:nodoc:
#         base.extend(ClassEval)
#         # Call the class method to setup validation for the password (which is really validation on a setter method).
#         # This is nessassary because the object never holds onto the plain text password.  The validaion of the plain
#         # text password must be done when the crypted_password is set (which happens in the set_password helper method).
#         base.send :validates_with_method, :add_password_errors
#       end
# 
#       # Supports initialization with a hash of methods & values.  It makes no difference if 
#       # the keys of the hash are strings or symbols, but they are case sensitive.
#       #
#       # keys:
#       #   :login        - (Optional) A String. This is required to set, authenticate, or reveal the password
#       #   :password     - (Optional) A String matching the password_confirmation
#       #   :password_confirmation - (Optional) A String matching the password
#       #   :password_requirements - (Optional) If provided, it must be a Proc that expects a String and returns true/false
#       def initialize(attributes = {}, &block)
#       
#         # accept string or symbol initiation data
#         attributes.map {|k,v| attributes[k.to_sym]=v if attributes.is_a? String}
# 
#         # Setup the login name, this may be any string even an email address.
#         @login = attributes[props[:login]] if attributes[props[:login]].is_a? String
#     
#         # Setup the password_requirements proc... the proc must receive a password string and return true/false
#         password_requirements &attributes[:password_requirements] if attributes[:password_requirements].is_a?(Proc)
#     
#         @auth_method = attributes[:auth_method] unless attributes[:auth_method].nil?
#     
#         # run the DataMapper initialize method (minus the password initializer password data)
#         super(attributes.reject {|k,v| k.to_s =~ /password(_confirmation)?/}, &block)
#         # begin
#         #   super(attributes.reject {|k,v| k.to_s =~ /password(_confirmation)?/}, attributes.reject {|k,v| k.to_s =~ /password(_confirmation)?/}, &block)
#         # rescue
#         #   super(attributes.reject {|k,v| k.to_s =~ /password(_confirmation)?/}, &block)
#         # end
#       
#         # Attempt to set the crypted password after the object has been otherwise fully loaded
#         # It will fail quietly if inadequate or falty information has been provided.
#         set_password(attributes[:password], attributes[:password_confirmation])
#         self
#       end
#     
#       attr_accessor :auth_method
# 
#       def auth_method #:nodoc:
#         @auth_method ||= encryption_type_from_property || ::AUTHENTICATABLE_RESOURCE['encryption_method']
#       end
# 
#       # Accepts a Proc to use for password password_requirements.  The proc should accept a String and return true or false.
#       # If no proc is provided then a non-blank password is required.
#       #
#       #   user = User.new
#       #   user.password_requirements = lambda {|pass| !pass.blank?}
#       # def password_requirements=(proc)
#       #   @password_requirements=proc if proc.is_a?(Proc)
#       # end
#     
#       # Sets the crypted_password.  
#       # 
#       # Perquisites: The login must already been set.  The password salt is the combination of the login and the system's salt
#       #
#       # Requires: (password, password_confirmation), which must match
#       def set_password(password, password_confirmation, encryption_method=self.auth_method)
#         return false unless password == password_confirmation 
#         return false unless self.send(props[:login]).is_a? String
#         return false unless is_valid_password? password
#         self.send( "#{props[:crypted_password]}=", encrypted(password, encryption_method))
#       end
#       
#       # 
#       def decrypt_password(crypted=false, key=encryption_key, encryption_mehtod=self.auth_method)
#         AES.decrypt(crypted||self.send(props[:crypted_password]), key, encryption_mehtod)
#       end
#       
#       # Defines the default password password_requirements.  Expects a password string.
#       #
#       # By default, passwords must be at least 5 characters long and must contain at characters from least two 
#       # of the following categories: uppercase, lowercase, numbers & symbols.
#       #
#       # Example default password method overide
#       #   class User
#       #     include DataMapper::AuthenticatableResource
#       #     # ... and some properties, etc. (you get the point) ...
#       #
#       #     password_reqirements do |pass|
#       #       errors=[] # error catcher
#       #       errors << 'must contain a mixture of: numbers & letters' unless /\w+\d+|\d+\w+/ =~ pass
#       #       errors << 'must be at least 5 characters long' unless pass.size > 4
#       #       errors.each {|error| self.errors.add(:password, error) } # adds validation errors
#       #       errors.blank?  # returns true if there are no errors or false if there are errors
#       #     end
#       #   end
#       def is_valid_password?(password)
#         return false unless password.is_a? String
#       
#         invalid_password_if /^([a-z]+|[A-Z]+|\d+|\W+)$/ =~ password, 'must contain characters from least two of the following categories: uppercase, lowercase, numbers & symbols'
#       
#         invalid_password_if password.size<5, 'must be 5 or more characters long'
# 
#         password_problems.blank?
#       end
#     
#       # Set the password requirements on a user instance...
#       #
#       # Example:
#       #   u = User.new
#       #   u.login = 'Something'
#       #   u.set_password 'Abc', 'Abc'  #=> false # doesn't meet the default password lenght policy.
#       #   u.password_requirements do |pass|
#       #     errors=[] # error catcher
#       #     errors << 'must begin with a capital' unless /^[A-Z]/ =~ pass
#       #     errors.nil?
#       #   end
#       #   u.set_password 'Abc', 'Abc'  #=> true
#       def password_requirements(&block) #:nodoc:
#         (class << self; self end).send(:define_method, :is_valid_password?, block)
#       end
# 
#       # # Convience Method to return the crypted_password and salt.  This method may make saving passwords
#       # # in the database easier.
#       # def pass_and_salt
#       #   [self.crypted_password, self.salt]
#       # end
# 
#       # Checks a given login and password against the encrypted data...  An encryption type may be supplied, however, 
#       # the authentication method may be infered more reliably.
#       # 
#       # Example:
#       #   user = User.new :login => 'user@example.com', :password => 'MySecret', :password_confirmation => 'MySecret'
#       #   user.authenticates_with? 'user@example.com', 'MySecret'      #=> true
#       #   user.authenticates_with? 'wrong@example.com', 'MySecret'     #=> false
#       #   user.authenticates_with? 'user@example.com', 'WrongSecret'   #=> false
#       def authenticates_with?(login, pass, encryption_type=nil)
#         return false unless self.send(props[:login]) == login
#         encrypted(pass, encryption_type) == self.send(props[:crypted_password])
#       end
#     
#     private
#       def encryption_type_from_property
#         if self.class.properties[props[:crypted_password]]
#           if self.class.properties[props[:crypted_password]].type.public_methods.include? 'encryption_type'
#             self.class.properties[props[:crypted_password]].type.encryption_type
#           else
#             nil
#           end
#         end
#       end
#       
#       def encryption_key
#         self.class.aes_key || ::AUTHENTICATABLE_RESOURCE['aes_key']
#       end
# 
#       def encrypted(string, encryption_method=nil)
#         case encryption_method = (encryption_method || self.auth_method).to_s.upcase
#         when 'SHA1'
#           Digest::SHA1.hexdigest string
#         when 'SHA2'
#           Digest::SHA2.hexdigest string
#         when 'MD5'
#           Digest::MD5.hexdigest string
#         when /^AES-?\d*(-ECB)?$/
#           AES.encrypt(string, encryption_key, encryption_method)
#         else
#           warn "I don't know how to do '#{encryption_method}' encryption.  Please check your config/password_encryption.yml"
#         end
#       end
# 
#       # Sets password validation error if the condition is true
#       def invalid_password_if(conditon, message)
#         conditon ? add_password_error(message) : remove_password_error(message)
#       end
# 
#       def add_password_errors
#         password_problems.collect {|msg| self.errors.add :password, msg}.blank?
#       end
#     
#       def password_problems
#         @password_problems||=[]
#       end
# 
#       def add_password_error(message)
#         password_problems << message
#       end
#     
#       def remove_password_error(message)
#         password_problems.delete(message)
#       end    
# 
#       def props
#         self.class.authentication_properties
#       end      
#     end
#   end
# end
