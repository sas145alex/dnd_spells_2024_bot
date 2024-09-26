class RaceDecorator < Draper::Decorator
  delegate_all

  def title
    object.title
  end
end
