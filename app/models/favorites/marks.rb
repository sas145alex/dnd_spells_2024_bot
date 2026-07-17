module Favorites
  # Marks the rows of a list screen that are already in the user's favorites, so a favorite is
  # recognizable while browsing any section or search result without opening its card. Resolves the
  # whole screen in one query — a 10-row list must not cost 10 `favorited?` checks — and marks
  # nothing when the user cannot use favorites.
  class Marks
    SYMBOL = "⭐".freeze

    def self.for(records, user)
      new(records, user)
    end

    def initialize(records, user)
      @records = records
      @user = user
    end

    def label(record, title)
      marked?(record) ? "#{SYMBOL} #{title}" : title
    end

    private

    attr_reader :records, :user

    def marked?(record)
      key = key_for(record)
      key.present? && favorited_keys.include?(key)
    end

    def favorited_keys
      return @favorited_keys if defined?(@favorited_keys)

      @favorited_keys = fetch_favorited_keys
    end

    def fetch_favorited_keys
      return Set.new unless Favorites::Policy.can_use?(user)

      keys = records.map { |record| key_for(record) }.compact
      return Set.new if keys.empty?

      user.favorites
        .where(favoritable_type: keys.map(&:first).uniq, favoritable_id: keys.map(&:last).uniq)
        .pluck(:favoritable_type, :favoritable_id)
        .map { |type, id| [type, id.to_s] }
        .to_set
    end

    # Keyed off the GlobalID every list row must already carry, because rows are not always the
    # record itself — some screens list POROs standing in for one (Presenters::CharacterAbilities-
    # Presenter::Variant, one row per level of the same ability).
    def key_for(record)
      record = record.object if record.is_a?(Draper::Decorator)
      return nil if record.is_a?(ActiveRecord::Base) && !record.is_a?(Favoritable)

      gid = GlobalID.parse(record.to_global_id)
      gid && [gid.model_name, gid.model_id.to_s]
    end
  end
end
