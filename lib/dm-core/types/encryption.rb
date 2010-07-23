module DataMapper
  class Property
    module EncryptionType
      module ClassMethods
        def encryption_type
          self.to_s.split('::').last
        end
        
        def digest(&block)
          @digest = block.nil? ? (@digest || lambda {}) : block
        end
      end
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def encryption_type
        self.encryption_type
      end
      
      def typecast(value)
        return nil if value.nil?
        ::Regexp.new("^[0-9a-f]{#{length}}$") === value ? value : self.class.digest.call(value)
      end
    end
  end
end
