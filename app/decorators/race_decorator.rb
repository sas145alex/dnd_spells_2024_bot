class RaceDecorator < ApplicationDecorator
  def title
    object.title
  end
end
