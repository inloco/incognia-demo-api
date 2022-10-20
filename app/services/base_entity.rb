class BaseEntity
  def initialize(attributes)
    attributes.each do |attribute, value|
      if respond_to?("#{attribute}=")
        method("#{attribute}=").call(value)
      else
        instance_variable_set("@#{attribute}", value)
      end
    end
  end
end
