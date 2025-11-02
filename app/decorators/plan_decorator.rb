class PlanDecorator < ApplicationDecorator
  def title
    "[#{object.level}] #{object.title}"
  end
end
