require File.expand_path(File.join File.dirname(__FILE__),'..','spec_helper')

describe 'Object extended with DataMapper::AuthenticatableResource::AES' do
  before :all do
    class AES
      extend DataMapper::AuthenticatableResource::AES
    end
    
    class AES_128
      extend DataMapper::AuthenticatableResource::AES
    end
    
    @data            = 'Hello World!'
    @key             = 'SuperSecret KEY that must be long enough'
    @AES_128         = "\b\243\021\373\034E\311?\vv\267\251\037\036\r5"
    @AES_192         = "\300\362K\350[\272\251\337\347_\311\252\215\231\314\r"
    @AES_256         = "\314\365\307\222\355\200W\252\261\220\330vz\244p\230"
  end

  %w(AES_128 AES_192 AES_256).each do |auth_method|
    it "should encrypt and decrypt #{auth_method} with full data" do
      AES.encrypt(@data, @key, auth_method).should == eval("@#{auth_method}")
      AES.decrypt(eval("@#{auth_method}"), @key, auth_method).should == @data
    end
  end
  
  it 'should respond to encryption_type' do
    AES_128.encryption_type.should == 'AES-128-ECB'
  end
  
  it 'should require a minimum key length' do
    #AES-128 requires a key of at least 16 characters
    lambda {AES.encrypt(@data, '123456789012345', 'AES-128')}.should raise_error
    lambda {AES.encrypt(@data, '1234567890123456', 'AES-128')}.should_not raise_error
    #AES-192 requires a key of at least 16 characters
    lambda {AES.encrypt(@data, '123456789012345', 'AES-128')}.should raise_error
    lambda {AES.encrypt(@data, '1234567890123456', 'AES-128')}.should_not raise_error
    #AES-256 requires a key of at least 32 characters
    lambda {AES.encrypt(@data, '1234567890123456789012345678901', 'AES-256')}.should raise_error
    lambda {AES.encrypt(@data, '12345678901234567890123456789012', 'AES-256')}.should_not raise_error
  end
  
  it 'should raise an error when a wrong key is given' do
    AES.decrypt(@AES_128, @key).should == @data
    lambda {AES.decrypt(@AES_128, 'WrongSecret KEY even if it is long enough').should == @data}.should raise_error
  end
end


# describe 'AES properties' do
#   before :all do
#     class SampleUser
#       include DataMapper::AuthenticatableResource
#       property :id, Serial
#       property :login,            String, :lazy => false, :required => true, :length => 100
#       property :crypted_password, AES_128, :lazy => false, :required => true
# 
#       aes_key '7a5W8*jGb7^5hgsJ'
# 
#       self.auto_migrate!
#     end
#     
#     SampleUser.new(:login => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word').save
#   end
# 
#   describe 'encryption' do
#     it 'should create a user with an encrypted password' do
#       SampleUser.first.crypted_password.should == SampleUser::AES.encrypt('Pa55word', '7a5W8*jGb7^5hgsJ', 'AES-128')
#     end
#   end
#   describe 'decryption' do
#     it 'should decrypt the password' do
#       SampleUser.first.decrypt_password.should == 'Pa55word'
#     end
#   end
# end
# 
