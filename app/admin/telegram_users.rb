ActiveAdmin.register TelegramUser do
  scope :active, ->(scope) { scope.active }
  scope :not_active, ->(scope) { scope.not_active }
end
