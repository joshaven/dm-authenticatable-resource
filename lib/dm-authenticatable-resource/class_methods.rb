# # Usage notes:
# #
# # A users model (of any name) should include: "DataMapper::AuthenticatableResource".  When this module is 
# # included, the model will be a DataMapper::Resource as well as including following methods: 
# #   :login, :crypted_password, :password_requirements, :auth_method, :set_password, :authenticates_with?, :is_valid_password?
# # Your database should store at least the following information: [@login, @crypted_password]
# # If your database schema does not contain columns for :login & :crypted_password, then you will 
# # need to write methods to handelers for :login & :crypted_password (see email example below).
# #
# # Example (User class using email for the authenticaiton login name):
# #   class User
# #     include DataMapper::AuthenticatableResource::Passwords
# #     ...
# #     # The following custom accessor is usefull if the database schema uses :email rather then :login for the login
# #     def email=(value) 
# #       @login = @email = value
# #     end
# #     ...
# #     def self.authenticate(email, pass)
# #       user = User.first :email => email
# #       user.authenticates_with?(email, pass) ? user : false
# #     end
# #   end
# #
# # Parameters used in Authenticator:
# #   :login              => Required String, there are no lenght or charactor stipulations for this field.
# #   :crypted_password   => This instance variable (String 32 characters or more) will be populated with the set_password method.
# #   :requirements       => Optional Proc.
# #   :auth_method        => String, one of: ['md5', 'sha1', 'sha2', 'AES-128', 'AES-192', 'AES-256'], 'AES' is the same as 'AES-128'
# #   :set_password       => Instance Method accepting: (password, password_confirmation) Strings.  :auth_method & :login must already be set.
# #   :authenticates_with? => Instance Method accepting: (login, pass) Strings.  This will return true/false
# #
# # Implementation:
# #   You will need to implement an authenticate class method
# # Setup environment variables
# 
# require 'digest'
# require File.join(File.dirname(__FILE__), 'authenticatable_resource', 'dm-core', 'encryption_type')
# 
# begin
#   unless defined? AUTHENTICATABLE_RESOURCE
#     secret = YAML.load_file("#{APP_ROOT}/config/password_encryption.yml") if
#     AUTHENTICATABLE_RESOURCE={}
#     AUTHENTICATABLE_RESOURCE['encryption_method'] = secret[:encryption_method].dup
#     AUTHENTICATABLE_RESOURCE['aes_key'] = secret[:aes_key].dup
#   end
# rescue
#   warn 'Could not read config/password_encryption.yml nor were the associated environment variables assigned.'
# end
# 
# module DataMapper
#   module AuthenticatableResource
#     # Load all .rb files in lib/authenticator and any subdirectories
#     require 'find'
#     Find.find(File.join(File.dirname(__FILE__), File.basename(__FILE__, '.rb'))) do |result|
#       require result if /\.rb$/ =~ result
#     end
#         
#     def self.included(base) #:nodoc:
#       # base.extend(ClassEval)
#       base.class_eval do
#         include DataMapper::Resource
#         include DataMapper::AuthenticatableResource::Passwords # It is crucial that this include follows the DataMapper::Resource
#       end
#     end
#   end
# end