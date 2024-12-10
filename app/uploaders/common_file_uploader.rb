class CommonFileUploader < ApplicationUploader
  EXTENSIONS = %w[jpg jpeg gif png].freeze

  storage :file

  def extension_allowlist
    EXTENSIONS
  end
end
