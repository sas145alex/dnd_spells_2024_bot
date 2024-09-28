ActiveAdmin.register Mention do
  menu false

  collection_action :options_for_select, method: :get do
    mentionable_klass = params[:mentionable_type].to_s.safe_constantize

    collection = if mentionable_klass.nil?
      []
    elsif mentionable_klass.in?([WildMagic])
      items = WildMagic.ordered.select(:id, :roll)
      items.map { |item| [item.id, item.decorate.title] }
    else
      mentionable_klass.ordered.pluck(:id, :title)
    end

    results = collection.map do
      {id: _1.first, text: _1.last.to_s}
    end

    render json: {
      results: results,
      pagination: {
        more: false
      }
    }
  end
end
