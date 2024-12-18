class InfusionDecorator < ApplicationDecorator
  def title
    "[#{object.level}] #{object.title}"
  end
end
