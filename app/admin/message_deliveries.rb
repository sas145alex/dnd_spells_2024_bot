ActiveAdmin.register MessageDelivery do
  actions :index, :show
  config.batch_actions = false

  scope :all, default: true
  scope("Отправлено") { |scope| scope.sent }
  scope("Ошибки") { |scope| scope.failed }
  scope("Ожидают") { |scope| scope.pending }

  filter :message_distribution, as: :select, collection: -> { MessageDistribution.order(created_at: :desc).pluck(:title, :id) }
  filter :external_id
  filter :recipient_type, as: :select, collection: %w[TelegramUser TelegramChat]
  filter :status, as: :select, collection: -> { MessageDelivery.statuses.keys }
  filter :error_reason, as: :select, collection: -> { MessageDelivery.error_reasons.keys }
  filter :created_at

  index do
    id_column
    column :message_distribution
    column :recipient_type
    column :external_id
    column :status
    column :error_reason
    column :sent_at
    actions defaults: false do |resource|
      link_to "Show", resource_path(resource), class: "btn btn-primary"
    end
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :message_distribution
      row :recipient_type
      row :recipient_id
      row :external_id
      row :status
      row :error_reason
      row :error_message
      row :sent_at
      row :created_at
      row :updated_at
    end
  end
end
