class Mention::GenerateOptionsForSelect < ApplicationOperation
  def initialize(mentionable_klass: nil)
    @mentionable_klass = mentionable_klass
  end

  def call
    collection.map do
      {id: _1.first, text: _1.last.to_s}
    end
  end

  private

  attr_reader :mentionable_klass

  def collection
    if mentionable_klass.nil?
      []
    elsif mentionable_klass.in?([WildMagic])
      items = WildMagic.ordered.select(:id, :roll)
      items.map { |item| [item.id, item.decorate.title] }
    else
      mentionable_klass.ordered.pluck(:id, :title)
    end
  end
end
