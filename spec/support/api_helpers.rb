module ApiHelpers
  def json_body
    @_json_body ||= begin
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      ""
    end
  end
end
