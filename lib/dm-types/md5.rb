module DataMapper::Types
  class MD5 < DataMapper::EncryptionType
    primitive String
    length    32
    digest    {|v| Digest::MD5.hexdigest(v)}
  end
end
