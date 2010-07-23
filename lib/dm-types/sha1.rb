module DataMapper
  class Property
    class SHA1 < String
      include DataMapper::Property::EncryptionType
      length    40
      digest    {|v| Digest::SHA1.hexdigest(v)}
    end
  end
end
