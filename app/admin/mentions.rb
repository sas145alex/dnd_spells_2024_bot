ActiveAdmin.register Mention do
  menu false

  collection_action :options_for_select, method: :get do
    collection = case params[:mentionable_type]
    when "Creature"
      Creature.order(title: :asc).pluck(:id, :title)
    when "Spell"
      Spell.order(title: :asc).pluck(:id, :title)
    when "WildMagic"
      items = WildMagic.order(roll: :asc).select(:id, :roll)
      items.all.map { |item| [item.id, item.decorate.title] }
    else
      []
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
