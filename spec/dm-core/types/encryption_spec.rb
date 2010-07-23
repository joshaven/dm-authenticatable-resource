require File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
 
describe DataMapper do#::EncryptionType do
  before :all do
    module DataMapper
      class Property
        class ET < String
          include DataMapper::Property::EncryptionType
          length    32
          digest    {|v| Digest::MD5.hexdigest(v)}
        end
      end
    end
  end
  
  it 'should respond to the :encryption_type class name without hierarchy' do
    DataMapper::Property::ET.encryption_type.should eql('ET')
  end
  
  it 'should respond to :digest' do
    DataMapper::Property::ET.digest.call('Hello').should eql(Digest::MD5.hexdigest('Hello'))
  end
  
  it 'should typecast properties' do
    class TestUser
      include DataMapper::AuthenticatableResource
      property :login, String, :key => true
      property :crypted_password, ET
    end
    t=TestUser.new(:login => 'JoeUser', :password=>'Hello', :password_confirmation=>'Hello')
    t.crypted_password = 'Hello'
    t.crypted_password.should == Digest::MD5.hexdigest('Hello')
  end
end