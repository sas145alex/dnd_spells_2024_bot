ActiveAdmin.register TelegramUser do
  permit_params :admin

  scope :active, ->(scope) { scope.active }
  scope :not_active, ->(scope) { scope.not_active }

  form do |f|
    f.inputs do
      f.input :admin
    end
    f.actions
  end

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
