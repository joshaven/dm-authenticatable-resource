require 'spec_helper'
 
describe DataMapper::AuthenticatableResource do
  it "should have a VERSION" do
    DataMapper::AuthenticatableResource::VERSION::STRING.should == "0.0.1"
  end
end
