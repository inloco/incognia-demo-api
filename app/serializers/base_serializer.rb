class BaseSerializer
  include ActiveModel::Serialization

  def to_hash
    self.serializable_hash.compact
  end

  def to_json(*args)
    self.to_hash.to_json(*args)
  end
end
