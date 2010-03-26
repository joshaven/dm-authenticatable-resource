class DataMapper::EncryptionType < DataMapper::Type
  def self.encryption_type
    self.to_s.split('DataMapper::Types::').join
  end
  
  def self.load(value, property)
    typecast(value, property)
  end

  def self.dump(value, property)
    typecast(value, property)
  end

  def self.typecast(value, property)
    return nil if value.nil?
    ::Regexp.new("^[0-9a-f]{#{length}}$") === value ? value : digest.call(value)
  end
private
  def self.digest(&block)
    @digest ||= lambda {}
    @digest = block.nil? ? @digest : block
  end
end
