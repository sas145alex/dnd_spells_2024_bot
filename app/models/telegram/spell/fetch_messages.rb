class Telegram::Spell::FetchMessages < ApplicationOperation
  MENTIONS_TO_RENDER = 7

  def initialize(spell)
    @spell = spell
  end

  def call
    messages = [spell.description]
    spell.mentions.limit(MENTIONS_TO_RENDER).each do |mention|
      messages << mention.another_mentionable.description
    end
    messages
  end

  private

  attr_reader :spell
end
