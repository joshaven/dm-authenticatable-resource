module DataMapper::Types
  class SHA1 < DataMapper::EncryptionType
    primitive String
    length    40
    digest    {|v| Digest::SHA1.hexdigest(v)}
  end
end
