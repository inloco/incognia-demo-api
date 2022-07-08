class BaseSerializer
  include ActiveModel::Serialization

  def to_hash
    self.serializable_hash.compact
  end

  def to_json
    self.to_hash.to_json
  end
end
