module DataMapper::Types
  class SHA2 < DataMapper::EncryptionType
    primitive String
    length    64
    digest    {|v| Digest::SHA2.hexdigest(v)}
  end
end
