# frozen_string_literal: true

require "rails_helper"

RSpec.describe Renderers::TelegramHTML do
  subject(:render) { renderer_instance_from.render(text) }
  let(:renderer_instance_to) { described_class.new }
  let(:renderer_instance_from) { Redcarpet::Markdown.new(renderer_instance_to) }
end
