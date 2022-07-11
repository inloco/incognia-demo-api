module I18nHelpers
  class << self
    def model_attribute_error(klass:, attribute:, error_key:, value: nil)
      prefix = "#{klass.i18n_scope}.errors.models.#{klass.model_name.i18n_key}.attributes"

      I18n.t("#{prefix}.#{attribute}.#{error_key}", value: value)
    end
  end
end
