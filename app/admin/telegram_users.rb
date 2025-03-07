ActiveAdmin.register TelegramUser do
  scope :active, ->(scope) { scope.active }
  scope :not_active, ->(scope) { scope.not_active }

  collection_action :autocomplete, method: :get do
    records = TelegramUser.autocomplete_search(params[:q])
    items = records.map do
      name = [_1.external_id, _1.username].join(" - ")
      {
        id: _1.external_id,
        text: name
      }
    end
    render json: {
      results: items
    }
  end
end
