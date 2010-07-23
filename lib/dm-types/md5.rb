module DataMapper
  class Property
    class MD5 < String
      include DataMapper::Property::EncryptionType
      length    32
      digest    {|v| Digest::MD5.hexdigest(v)}
    end
  end
end
