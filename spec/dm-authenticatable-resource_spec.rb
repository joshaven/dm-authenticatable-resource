require File.expand_path File.join(File.dirname(__FILE__), 'spec_helper')
 
describe DataMapper::AuthenticatableResource do
  it "should have a VERSION" do
    DataMapper::AuthenticatableResource::VERSION::STRING.should == "0.0.2"
  end
end
