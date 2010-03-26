require File.expand_path File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
 
describe DataMapper do#::EncryptionType do
  before :all do
    @et = DataMapper::EncryptionType
  end
  
  it "should respond to the :encryption_type class method" do
    @et.encryption_type.should eql('DataMapper::EncryptionType')
  end
  
  it 'should be a DataMapper::Type' do
    DataMapper::EncryptionType.new.should be_a_kind_of(DataMapper::Type)
  end
end