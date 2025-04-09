ActiveAdmin.register TelegramUser do
  scope :active, ->(scope) { scope.active }
  scope :not_active, ->(scope) { scope.not_active }

  collection_action :autocomplete, method: :get do
    records = TelegramUser.autocomplete_search(params[:q])
    items = records.map do
      name = [it.external_id, it.username].join(" - ")
      {
        id: it.external_id,
        text: name
      }
    end
    render json: {
      results: items
    }
  end
end
