module Presenters
  # Builds the flat list of "pick_mention" buttons for a record's cross-references. Single source
  # for both the shared card renderer (Presenters::LeafCard) and the hand-built menu screens
  # (BaseCommand#keyboard callers). Preloads `another_mentionable` so a card's mentions load in one
  # query per referenced type instead of one per mention.
  module MentionButtons
    def self.for(record)
      return [] unless record.respond_to?(:mentions)

      record.mentions.includes(:another_mentionable).map do |mention|
        {
          text: mention.another_mentionable.decorate.title,
          callback_data: "pick_mention:#{mention.id}"
        }
      end
    end
  end
end
