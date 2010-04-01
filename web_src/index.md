# DataMapper::AuthenticatableResource
* Documentation:  http://auth-resource.rubyforge.org/rdoc
* Website:        http://auth-resource.rubyforge.org/
* Author:         Joshaven Potter <yourtech@gmail.com>

## Description
A DataMapper::Resource with authentication baked in.

## Purpose
DataMapper::AuthenticatableResource assists in drying up a DataMapper user models.  It handles encryption, password 
requirements, and authentication.  Simplicity and security is sanity.

## Installation
    gem install dm-authenticatable-resource

## Supported Encryption Methods:

By Example:

    property :crypted_password, MD5
    property :crypted_password, SHA1
    property :crypted_password, SHA2
    property :crypted_password, AES_128
    property :crypted_password, AES_192
    property :crypted_password, AES_256
    
## Examples

### Password with AES 256-bit reversible encryption
    class User
      include DataMapper::AuthenticatableResource
      property :id, Serial
      property :login,            String,   :required => true, :length => 100
      property :crypted_password, AES_256,  :required => true
    
      aes_key '7a5W8*jGb7^5hgsJ2a!@#Romans13:14'  # It is advisable to load this value from a 
                                                  # file that is outside of all code repositories!
    end
    
    u = User.new(:login => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word')
    => #<User @id=nil @login="joe@example.com" @crypted_password="\340\250v}Q2\253\324\224\263\343I\300\270q\222">
    u.decrypt_password
    => "Pa55word"
    u.authenticates_with? 'joe@example.com', 'Pa55word'
    => true
### Password with SHA-2 encrypted one way password
    class User
      include DataMapper::AuthenticatableResource
      property :id, Serial
      property :login,            String, :required => true, :length => 100
      property :crypted_password, SHA2,   :required => true
    end
    
    u = User.new(:login => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word')
    #<User @id=nil @login="joe@example.com" @crypted_password="39f48fdb481a1525a50e7c2080605ffe0f332543db0868d0c25ceb545472038d">
    u.authenticates_with? 'joe@example.com', 'Pa55word'
    => true
    u.authenticates_with? 'joe@example.com', 'Password'
    => false

## Quick API by Example
### Redefine :login and :crypted_password methods 
    class User
      include DataMapper::AuthenticatableResource
      property :id, Serial
      property :email,    String, :required => true, :length => 100
      property :password, SHA1,   :required => true

      authentication_properties :login => :email, :crypted_password => :password      
    end

### Redefine :password_requirements
    class User
      include DataMapper::AuthenticatableResource
      property :id, Serial
      property :email,    String, :required => true, :length => 100
      property :password, MD5,    :required => true

      password_requirements do |pass|
        invalid_password_unless /[A-Z]/ ~= pass,  'must contain a capital letter'
        invalid_password_if     pass.length < 5,  'must be at least 5 characters long'
        password_problems.blank?
      end
    end

### Authenticate a user
    u = User.first :email => 'joe@example.com'
    u.authenticates_with? 'joe@example.com', 'Pa55word'  # returns true/false
