module EditionSourceable
  extend ActiveSupport::Concern

  # Which book / edition a record was published in. Values are the exact strings
  # already stored in Creature#edition_source, so the enum is drop-in reusable there.
  EDITION_SOURCES = {
    ravenloft: "Ravenloft",
    efota: "EFotA",
    ua25: "UA25",
    ai: "AI",
    mm25: "MM25",
    phb24: "PHB24",
    dmg24: "DMG24",
    ua26: "UA26"
  }.freeze

  included do
    enum :edition_source, EDITION_SOURCES
  end
end
