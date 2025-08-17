class Mention::GenerateOptionsForSelect < ApplicationOperation
  def initialize(mentionable_klass: nil)
    @mentionable_klass = mentionable_klass
  end

  def call
    collection.map do
      {id: it.first, text: it.last.to_s}
    end
  end

  private

  attr_reader :mentionable_klass

  def collection
    items = if mentionable_klass.nil?
      []
    else
      mentionable_klass.ordered
    end
    items.to_a.map { |item| [item.id, item.decorate.admin_mention_title] }
  end
end
