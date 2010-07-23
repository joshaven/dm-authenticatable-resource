module DataMapper
  class Property
    class SHA2 < String
      include DataMapper::Property::EncryptionType
      length    64
      digest    {|v| Digest::SHA2.hexdigest(v)}
    end
  end
end
