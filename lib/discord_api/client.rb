module DiscordAPI
  class Client
    attr_reader :webhook

    def initialize(webhook: nil)
      @webhook = webhook
    end

    def send_message(message = nil, username: nil, embeds: [])
      params = {}.tap do |hash|
        hash[:message] = message if message.present?
        hash[:username] = username if username.present?
        hash[:embeds] = embeds if embeds.present?
      end

      post(params)
    end

    private

    def post(params)
      return unless configured?

      response = HTTParty.post(webhook, body: params.to_json, headers: {"Content-Type" => "application/json"})
      return response if response.success?
      raise APIError, "Code: #{response.code}; Body: #{response.body}"
    end

    def configured?
      webhook.present?
    end
  end
end
