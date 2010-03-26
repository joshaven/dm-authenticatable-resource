module DataMapper::Types
  class AES_128 < DataMapper::Type #:nodoc:
    extend DataMapper::AuthenticatableResource::AES
    primitive Text
    
    attr_accessor :encrypted
  
    def self.load(value, property)
      typecast(value, property)
    end
  
    def self.dump(value, property)
      typecast(value, property)
    end
  
    def self.typecast(value, property)
      return nil if value.nil?
      value.is_binary_data? ? value : encrypt('Pa55word', property.model.aes_key, 'AES-128-ECB')
    end
  end
  
  class AES_192 < DataMapper::Type #:nodoc:
    extend DataMapper::AuthenticatableResource::AES
    primitive Text
    
    attr_accessor :encrypted
  
    def self.load(value, property)
      typecast(value, property)
    end
  
    def self.dump(value, property)
      typecast(value, property)
    end
  
    def self.typecast(value, property)
      return nil if value.nil?
      value.is_binary_data? ? value : encrypt('Pa55word', property.model.aes_key, 'AES-192-ECB')
    end
  end
  
  class AES_256 < DataMapper::Type #:nodoc:
    extend DataMapper::AuthenticatableResource::AES
    primitive Text
    
    attr_accessor :encrypted
  
    def self.load(value, property)
      typecast(value, property)
    end
  
    def self.dump(value, property)
      typecast(value, property)
    end
  
    def self.typecast(value, property)
      return nil if value.nil?
      value.is_binary_data? ? value : encrypt('Pa55word', property.model.aes_key, 'AES-256-ECB')
    end
  end
end
