class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.human_enum_names(enum_name, enum_value = nil, locale: nil)
    enum_i18n_key = enum_name.to_s.pluralize
    if enum_value
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_i18n_key}.#{enum_value}", locale: locale)
    else
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_i18n_key}", locale: locale)
    end
  end

  def human_enum_name(enum_name, locale: nil)
    enum_value = public_send(enum_name)
    self.class.human_enum_names(enum_name, enum_value, locale: locale)
  end
end
