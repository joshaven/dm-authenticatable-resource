module DataMapper
  class Property
    class AES_128 < Text #:nodoc:
      include DataMapper::Property::EncryptionType
      extend DataMapper::AuthenticatableResource::AES
    
      attr_accessor :encrypted

      def typecast(value)
        return nil if value.nil?
        value.is_binary_data? ? value : encrypt(value, property.model.aes_key, 'AES-128-ECB')
      end
    end

    class AES_192 < Text #:nodoc:
      include DataMapper::Property::EncryptionType
      extend DataMapper::AuthenticatableResource::AES
      
      attr_accessor :encrypted
      
      def typecast(value)
        return nil if value.nil?
        value.is_binary_data? ? value : encrypt(value, property.model.aes_key, 'AES-192-ECB')
      end
    end
  
    class AES_256 < Text #:nodoc:
      include DataMapper::Property::EncryptionType
      extend DataMapper::AuthenticatableResource::AES
    
      attr_accessor :encrypted
  
      def typecast(value)
        return nil if value.nil?
        value.is_binary_data? ? value : encrypt(value, property.model.aes_key, 'AES-256-ECB')
      end
    end
  end
end
