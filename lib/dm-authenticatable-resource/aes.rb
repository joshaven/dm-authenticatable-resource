require 'openssl'

module DataMapper
  module AuthenticatableResource
    module AES
      # Returns the encryption type based upon the class type... ie AES_128 will yeald: AES-128-ECB
      def encryption_type
        self.to_s.split('DataMapper::Types::').join.gsub('_','-') + '-ECB'
      end
      
      # Encrypts the given data with the given encryption key and optional, type of encryption.  
      # Cipher_type should be "AES-128", "AES-192", or "AES-256".  If none is given "AES-128" will be assumed.
      #
      # DataMapper::AuthenticatableResource::AES.encrypt "Hello World!", 'Secret KEY that must be long enough', 'AES-256'
      # => "qJ\361\270\231\250\241\263S\271\262s\271$\214\337"
      def encrypt(data, key, cipher_type=nil)
        cipher :encrypt, data, key, cipher_type
      end

      # Decrypts the encrypted_data that is given with the given encryption key and optional, type of encryption.  
      # Cipher_type should be "AES-128", "AES-192", or "AES-256".  If none is given "AES-128" will be assumed.
      #
      #   DataMapper::AuthenticatableResource::AES.decrypt "qJ\361\270\231\250\241\263S\271\262s\271$\214\337", 'Secret KEY that must be long enough', 'AES-256'
      #   => "Hello World!"
      #
      # A wrong key will raise an error
      #   DataMapper::AuthenticatableResource::AES.decrypt "qJ\361\270\231\250\241\263S\271\262s\271$\214\337", 'Wrong KEY that must be long enough', 'AES-256'
      #   => OpenSSL::Cipher::CipherError: bad decrypt ...
      def decrypt(encrypted_data, key, cipher_type=nil)
        cipher :decrypt, encrypted_data, key, cipher_type
      end
    private
      def cipher(direction, data, key, cipher_type=nil)
        # Cleanup input to make everyone else's life easier
        cipher = (cipher_type || 'AES-128').dup.to_s
        cipher = 'AES-128' if cipher.empty?
        cipher.upcase!
        cipher.gsub!('_','-')
        cipher = cipher + '-128' if /^AES$/ === cipher # default AES to AES-128
        cipher = cipher + '-ECB' if /^AES-\d+$/ === cipher # default AES-??? to AES-???-ECB (doesn't require an initialization vector)
        # Encrypted or Decript
        aes = OpenSSL::Cipher::Cipher.new(cipher)
        aes.__send__(direction)
        aes.key = key
        aes.update(data) + aes.final
      end
    end
  end
end