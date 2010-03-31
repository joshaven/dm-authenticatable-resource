module DataMapper::AuthenticatableResource
  
  module ClassMethods
    # Class Method to set custom methods for :login or :crypted_password.  
    #
    # For example
    #   class User
    #     include DataMapper::AuthenticatableResource
    #     property :id, Serial
    #     property :email,      String
    #     property :password,   SHA2
    #     self.authentication_properties {:login => 'email', :crypted_password => 'password'}
    #   end
    def authentication_properties(props = {})
      @authentication_properties ||= {:login => :login, :crypted_password => :crypted_password}
      @authentication_properties.merge!( props.reject {|k,v| k unless k == :login || k == :crypted_password} )
    end
    
    # Set the password requirements on a class that includes DataMapper::AuthenticatableResource.
    #
    # Helper methods that really help:
    #   invalid_password_if( expression, 'failure message to raise' )
    #   invalid_password_unless( expression, 'failure message to raise' )  
    #   password_problems      # Returns an array of password issues, if its blank then your good to go.
    #
    # Example:
    #   class User
    #     include DataMapper::AuthenticatableResource
    #     property :id, Serial
    #     property :email,      String
    #     property :password,   SHA2
    #     # The following will cause instances of this object to only accept passwords that 
    #     # begin with a capital letter unless the instance has a password_requirement, which
    #     # will override the password_requirements defined in the class.
    #     password_requirements do |pass|
    #       invalid_password_if pass.length<5, 'must be at least 5 characters long'
    #       password_problems.blank?
    #     end
    #   end
    def password_requirements(&block) #:nodoc:
      self.send(:define_method, :is_valid_password?, block)
    end
    
    # AES encryption key getter and setter
    # attr_accessor :aes_key
    def aes_key(key=nil)
      key.nil? ? @aes_key : @aes_key = key
    end
    def aes_key=(key)
      @aes_key=key
    end
    
  end
  
  module InstanceMethods
    # Supports initialization with a hash of methods & values.  It makes no difference if 
    # the keys of the hash are strings or symbols, but they are case sensitive.
    #
    # keys:
    #   :login        - (Optional) A String. This is required to set, authenticate, or reveal the password
    #   :password     - (Optional) A String matching the password_confirmation
    #   :password_confirmation - (Optional) A String matching the password
    #   :password_requirements - (Optional) If provided, it must be a Proc that expects a String and returns true/false
    #   :auth_method  - (optional) A String or DataMapper Type Object, ie: 'SHA1', DataMapper::Types::MD5, 'AES-192', etc
    #
    # Notes:
    #   - The :password & :password_confirmation are special in that they are sent to the 
    #     set_password method and are not otherwise used
    #   - The login & crypted_password are the default authentication properities but can
    #     be overwritten with the :authentication_properties class method
    def initialize(attributes = {}, &block)
      # accept string or symbol initiation data
      attributes.map {|k,v| attributes[k.to_sym]=v if attributes.is_a? String}
  
      # Setup the password_requirements proc... the proc must receive a password string and return true/false
      password_requirements &attributes[:password_requirements] if attributes[:password_requirements].is_a?(Proc)
  
      @auth_method = attributes[:auth_method] unless attributes[:auth_method].nil?
  
      # run the DataMapper initialize method (minus the password initializer password data)
      super(attributes.reject {|k,v| k.to_s =~ /password(_confirmation)?/}, &block)
    
      # Attempt to set the crypted password after the object has been otherwise fully loaded
      # It will fail quietly if inadequate or falty information has been provided.
      set_password(attributes[:password], attributes[:password_confirmation])
      self
    end
    
    attr_accessor :auth_method

    def auth_method #:nodoc:
      @auth_method ||= encryption_type_from_property
    end
    
    # Tests a given password string against the defined password requirements.
    #
    # By default, passwords must be at least 5 characters long and must be composed of multiple 
    # character types: uppercase, lowercase, numbers & symbols... ie: 'Password' or 'start123' or 'kA%28'
    #
    # To overide the default password requirements see password_requirements instance and or class methods.
    def is_valid_password?(password)
      return false unless password.is_a? String
    
      invalid_password_if /^([a-z]+|[A-Z]+|\d+|\W+)$/ =~ password, 'must contain characters from least two of the following categories: uppercase, lowercase, numbers & symbols'
    
      invalid_password_if password.size<5, 'must be 5 or more characters long'

      password_problems.blank?
    end

    # Set the password requirements on a DataMapper::AuthenticatableResource instance...
    #
    # Helper methods that really help:
    #   invalid_password_if( expression, 'failure message to raise' )
    #   invalid_password_unless( expression, 'failure message to raise' )
    # Example:
    #   u = User.new
    #   u.login = 'Something'
    #   u.set_password 'Abc', 'Abc'  #=> false # doesn't meet the default password length policy.
    #   u.password_requirements do |pass|
    #     invalid_password_unless /^[A-Z]/ =~ pass, 'must begin with a capital'
    #     password_problems.blank?
    #   end
    #   u.set_password 'Abc', 'Abc'  #=> true
    def password_requirements(&block) #:nodoc:
      (class << self; self end).send(:define_method, :is_valid_password?, block)
    end
    
    
    # Accepts a Proc to use for password password_requirements.  The proc should accept a String and return true or false.
    # If no proc is provided then a non-blank password is required.
    #
    #   user = User.new
    #   user.password_requirements = lambda {|pass| !pass.blank?}
    # def password_requirements=(proc)
    #   @password_requirements=proc if proc.is_a?(Proc)
    # end
  
    # Sets the crypted_password.  
    # 
    # Perquisites: The login must already been set.  The password salt is the combination of the login and the system's salt
    #
    # Requires: (password, password_confirmation), which must match
    def set_password(password, password_confirmation, encryption_method=self.auth_method)
      return false unless password == password_confirmation 
      return false unless self.send(props[:login]).is_a? String
      return false unless is_valid_password? password
      self.send( "#{props[:crypted_password]}=", encrypted(password, encryption_method))
    end
  
    # Checks a given login and password against the encrypted data...  An encryption type may be supplied, however, 
    # the authentication method may be infered more reliably.
    # 
    # Example:
    #   user = User.new :login => 'user@example.com', :password => 'MySecret', :password_confirmation => 'MySecret'
    #   user.authenticates_with? 'user@example.com', 'MySecret'      #=> true
    #   user.authenticates_with? 'wrong@example.com', 'MySecret'     #=> false
    #   user.authenticates_with? 'user@example.com', 'WrongSecret'   #=> false
    def authenticates_with?(login, pass, encryption_type=nil)
      return false unless self.send(props[:login]) == login
      encrypted(pass, encryption_type) == self.send(props[:crypted_password])
    end
    
    # Returns the decrypted password.
    #
    # Optional params:
    #   - crypted: the encrypted version of the password, should already be avilable via the crypted password properity
    #   - encryption_key: the key used to encrypt the password, should be inferred
    #   - encryption_method: The method used to encrypt the password, should be infered from the class or instance
    def decrypt_password(crypted=false, key=encryption_key, encryption_mehtod=self.auth_method)
      self.class.decrypt(crypted||self.send(props[:crypted_password]), key, encryption_mehtod)
    end
    
  private
    def encryption_type_from_property
      if self.class.properties[props[:crypted_password]]
        if self.class.properties[props[:crypted_password]].type.public_methods.include? 'encryption_type'
          self.class.properties[props[:crypted_password]].type.encryption_type
        else
          nil
        end
      end
    end
  
    def encryption_key
      self.class.aes_key
    end

    def encrypted(string, encryption_method=nil)
      case encryption_method = (encryption_method || self.auth_method).to_s.upcase
      when 'SHA1'
        Digest::SHA1.hexdigest string
      when 'SHA2'
        Digest::SHA2.hexdigest string
      when 'MD5'
        Digest::MD5.hexdigest string
      when /^AES-?\d*(-ECB)?$/
        self.class.encrypt(string, encryption_key, encryption_method)
      else
        warn "I don't know how to do '#{encryption_method}' encryption.  Please check your config/password_encryption.yml"
      end
    end

    # Sets password validation error if the condition is true
    def invalid_password_if(conditon, message)
      conditon ? add_password_error(message) : remove_password_error(message)
    end

    def invalid_password_unless(conditon, message)
      conditon ? remove_password_error(message) : add_password_error(message)
    end

    def add_password_errors
      password_problems.collect {|msg| self.errors.add :password, msg}.blank?
    end

    def password_problems
      @password_problems||=[]
    end

    def add_password_error(message)
      password_problems << message
    end

    def remove_password_error(message)
      password_problems.delete(message)
    end    
  
    def props
      self.class.authentication_properties
    end      
  end
  
  def self.included(base) #:nodoc:
    base.class_eval do
      include DataMapper::Resource
      extend ClassMethods
      include InstanceMethods
      extend DataMapper::AuthenticatableResource::AES
    end
    base.send :validates_with_method, :add_password_errors
  end
end
