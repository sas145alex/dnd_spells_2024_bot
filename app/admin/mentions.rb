ActiveAdmin.register Mention do
  menu false

  collection_action :options_for_select, method: :get do
    mentionable_klass = params[:mentionable_type].to_s.safe_constantize
    results = Mention::GenerateOptionsForSelect.call(mentionable_klass: mentionable_klass)

    render json: {
      results: results,
      pagination: {
        more: false
      }
    }
  end
end
