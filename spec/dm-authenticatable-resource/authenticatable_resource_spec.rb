require File.expand_path(File.join File.dirname(__FILE__),'..','spec_helper')

# DataMapper::AuthenticatableResource::Passwords is a module designed to be used as part of a authenticatable class, like users... hence the example
class TestUser
  include DataMapper::AuthenticatableResource

  property :id,               Serial
  property :name,             String, :required => true
  property :login,            String, :required => true
  property :crypted_password, Text,   :required => true # The type here would generally be set to somethign like SHA2 not Text
  property :auth_method,      String  # Adding this method allows the crypted_password encryption method to be stored in the database
                                      # without it recalled password encryption methods would not be descernable without specifying the 
                                      # encryption type with the properity which would be a bit too spicific for getting the tests I want.
  auto_migrate!
end

describe 'Password' do
  describe 'Creation' do
    it 'should receive a login, password, & password_confirmation on initialization and set the crypted_password' do
      u = create_user
      u.crypted_password.should == Digest::SHA1.hexdigest('Pa55word')
      u.should be_valid
    end

    it 'should set the password with the set method once a login has been provided' do
      u = TestUser.new :auth_method => 'SHA2'
      u.set_password('Pa55word', 'Pa55word').should be_false
      u.login = 'user@example.com'
      
      sha_pass = Digest::SHA2.hexdigest('Pa55word')
    
      u.set_password('Pa55word','wrong').should be_false
      u.crypted_password.should be_nil
    
      u.set_password('Pa55word', 'Pa55word').should == sha_pass
      u.crypted_password.should == sha_pass
    
      u.set_password('Pa55word','wrong').should be_false
      u.crypted_password.should == sha_pass
        
      # change the password
      u.set_password('new_password','new_password')
      
      u.crypted_password.should == Digest::SHA2.hexdigest('new_password')
    end
    
    # it 'should be able to substitue login with email when the setter is configured' do
    #   # For a similar feature that may suit better, see the the description: "with custom login & crypted_password properties"
    #   TestUser.send :define_method, :email= do |value|
    #     self.login = @email = value.to_s.downcase
    #   end
    #   
    #   TestUser.instance_methods.should include('email=')
    #   
    #   u=TestUser.new({:name => 'Joe User', :email => 'user@test.com', :password => 'Pa55word', :password_confirmation => 'Pa55word', :auth_method => DataMapper::Types::MD5})
    #   u.should be_valid
    #   
    #   TestUser.class_eval { undef :email= }
    #   TestUser.instance_methods.should_not include('email=')
    # end

    describe 'with custom login & crypted_password properties' do
      it 'should be valid on initialization, given a handeler' do
        class TempTestUser
          include DataMapper::AuthenticatableResource
          property :id,       Serial
          property :email,    String
          property :password, MD5
          auto_migrate!
          authentication_properties :login => :email, :crypted_password => :password
        end
      
        TempTestUser.new(:email => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word').save
        TempTestUser.first.email.should == 'joe@example.com'
      end
    end
  end
  
  describe 'Requirements' do
    it 'should envorce default password requirementsts' do
      u = TestUser.new :login => 'joeuser', :name => 'Joe User', :auth_method => 'SHA2'
      u.crypted_password.should be_nil
      u.is_valid_password?('invalidpassword').should be_false
      u.is_valid_password?('Passwd').should be_true
      u.set_password('invalidpassword', 'invalidpassword').should be_false
      u.crypted_password.should be_nil
      u.set_password('Passwd', 'Passwd').should be_true
      u.crypted_password.should eql(Digest::SHA2.hexdigest('Passwd'))
    end
  
    it 'should have intelegent validation errors when the password requirements are not met' do
      u = create_user :password => 'a5', :password_confirmation => 'a5'
      u.should_not be_valid
      u.errors[:password].should include('must be 5 or more characters long')      
    end
    
    it 'should enforce minimum password requiremnts as set on the instance but not be persistent on the class' do
      password_requirements = Proc.new do |pass|
        invalid_password_if pass != 'silly', 'must be silly'
        password_problems.blank?
      end
      u=create_user :password_requirements => password_requirements
      u.should_not be_valid
      u.set_password 'silly', 'silly'
      u.should be_valid
      
      u2=create_user
      u2.should be_valid
    end
      
    it 'should accept password requiremnts using the invalid_password_unless' do
      password_requirements = Proc.new do |pass|
        invalid_password_unless /^[A-Z]/ =~ pass, 'must begin with a capital'
        password_problems.blank?
      end
      
      u=create_user :password_requirements => password_requirements
      u.set_password('silly4u', 'silly4u').should be_false
      u.set_password('Silly4u', 'Silly4u').should be_true
    end
        
    it 'should enforce persistent minimum password requirements when set on the class' do
      # Backup password_requirements
      TestUser.instance_eval do
        alias_method :original_password_validation, :is_valid_password?
      end
      
      TestUser.password_requirements do |pass|
        invalid_password_unless pass == 'silly', 'must be silly'
        password_problems.blank?
      end
      u = create_user :name => 'silly man', :login => 'testuser'
      
      u.set_password('silly1', 'silly1').should_not be_true
      u.should_not be_valid
      u.errors[:password].should include('must be silly')
      
      u.set_password('silly', 'silly').should be_true
      u.should be_valid
      
      # Reset the class password_requirements to be nice to the remainder of the tests
      TestUser.instance_eval do 
        alias_method :is_valid_password?, :original_password_validation
      end
    end
      
    it 'should ensure that instance requirements override the class requirements' do
      create_user(:password => '123', :password_conformation => '123').should_not be_valid
      create_user(:password => '123', :password_conformation => '123', :password_requirements => lambda {|pass| true}).should be_true
      create_user(:password => '', :password_conformation => '', :password_requirements => lambda {|pass| true}).should be_true
    end
  end
  
  describe 'Authentication' do
    before :each do
      TestUser.auto_migrate!
    end
    it 'should authenticate when given the proper login & password' do
      create_user.save
      u = TestUser.first 

      u.authenticates_with?('user@example.com', 'Pa55word').should be_true
      u.authenticates_with?('user@example.com', 'wrong').should be_false
      u.authenticates_with?('wrong@example.com', 'Pa55word').should be_false
    end
    
    it 'should authenticate on the class' do
      create_user.save 
      TestUser.authenticate('user@example.com', 'Pa55word').should be_true
    end
  end
  
  describe 'Encryption Methods' do
    describe 'set in class definition' do
      %w(MD5 SHA1 SHA2).each do |auth_method|
        it "should autoset the encryption type based upon the property type for #{auth_method}" do
          eval "class TemporaryUser
                  include DataMapper::AuthenticatableResource
                  property :id, Serial
                  property :login,            String, :lazy => false, :required => true, :length => 100
                  property :crypted_password, #{auth_method},   :lazy => false, :required => true
                  auto_migrate!
                end"
  
          TemporaryUser.new(:login => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word').save.should be_true
          TemporaryUser.first.crypted_password.should == eval("Digest::#{auth_method}.hexdigest('Pa55word')")
        end
      end
    
      %w(AES_128 AES_192 AES_256).each do |auth_method|
        it "should autoset the encryption type based upon the property type for #{auth_method}" do
          eval "class TemporaryUser
                  include DataMapper::AuthenticatableResource
                  property :id, Serial
                  property :login,            String
                  property :crypted_password, #{auth_method}
                  self.aes_key='Something long enought to be an encryption key'
                  auto_migrate!
                end"
          TemporaryUser.new(:login => 'joe@example.com', :password=>'Pa55word', :password_confirmation=>'Pa55word').save.should be_true
          TemporaryUser.first.crypted_password.should == TemporaryUser.encrypt('Pa55word', TemporaryUser.aes_key, auth_method)
        end
      end
    end
    
    describe 'specified durring initialization' do
      before :all do
        TestUser.aes_key = 'Something long enought to be an encryption key'
      end
      
      %w(MD5 SHA1 SHA2).each do |auth_method|
        it "should support #{auth_method} password encryption" do
          create_user(:auth_method => auth_method).crypted_password.should == eval("Digest::#{auth_method}.hexdigest('Pa55word')")
        end
      end
  
      %w(AES-128 AES-192 AES-256).each do |auth_method|
        it "should support #{auth_method} reversable encryption" do
          u = create_user :auth_method=>auth_method
          u.crypted_password.should eql TestUser.encrypt('Pa55word', TestUser.aes_key, auth_method)
          u.decrypt_password.should eql 'Pa55word'
        end
      end
    end
  end
  
private
  def create_user(options={})
    TestUser.new({:name => 'Joe User', :login => 'user@example.com', :password => 'Pa55word', :password_confirmation => 'Pa55word',  :auth_method => 'SHA1'}.merge(options))
  end
end
