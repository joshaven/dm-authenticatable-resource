require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')


describe 'Object creation with value of type' do
  %w(MD5 SHA1 SHA2).each do |encryption_method|
    describe "#{encryption_method}" do
      before :all do
        @value, @crypt = 'Hello World!', eval("Digest::#{encryption_method}").hexdigest('Hello World!')
        @dm_type = eval("DataMapper::Property::#{encryption_method}")
      end
      it 'should create object with encrypted value when specified on initialization' do
        t = create_obj_with_value_class @dm_type, {:value=>@value}
        t.value.should == @crypt 
      end
    
      it 'should create object with encrypted value when specified after initialization' do
        t = create_obj_with_value_class @dm_type
        t.value.should be_blank
        t.value = @value
        t.value.should == @crypt
      end
      
      it 'should save the encrypted value properly' do
        create_obj_with_value_class(@dm_type, {:value=>@value}).save
        Scrap.first.value.should == @crypt
      end
    end
  end  
end


def create_obj_with_value_class(valueClass, options={})
  # Remove Scrap Object, ensures that we have a clean Scrap
  Object.send(:remove_const, :Scrap) if Object.const_defined?(:Scrap)
  # Create a Scrap Object with the dynamic value property
  eval "class Scrap
          include DataMapper::Resource
          property :id, Serial
          property :value, #{valueClass}
          self.auto_migrate!
        end"
  # Return a scrap instance
  Scrap.new(options)
end


