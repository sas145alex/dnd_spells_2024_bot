class ApplicationUploader < CarrierWave::Uploader::Base
  EXTENSIONS = %w[].freeze

  def self.whitelisted_extensions
    self::EXTENSIONS.map { ".#{_1}" }.join(",")
  end
end
