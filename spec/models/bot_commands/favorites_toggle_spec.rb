require "rails_helper"

RSpec.describe BotCommands::FavoritesToggle do
  subject(:result) { described_class.call(user: user, gid: gid, inline_keyboard: inline_keyboard) }

  let(:user) { create(:telegram_user, :admin) }
  let(:record) { create(:spell) }
  let(:gid) { record.to_global_id.to_s }
  let(:inline_keyboard) do
    [
      [{"text" => "⭐ В избранное", "callback_data" => "fav:#{gid}"}],
      [{"text" => "Назад", "callback_data" => "go_back:go_back"}]
    ]
  end

  context "when the record is not yet favorited" do
    it { expect { result }.to change { user.favorites.count }.by(1) }
    it { expect(result[:toast]).to eq("Добавлено в избранное ⭐") }

    it "flips the tapped button to the remove label and leaves the rest intact" do
      keyboard = result[:inline_keyboard]
      expect(keyboard.first.first["text"]).to eq("❌ Убрать из избранного")
      expect(keyboard.last).to eq([{"text" => "Назад", "callback_data" => "go_back:go_back"}])
    end
  end

  context "when the record is already favorited" do
    before { create(:favorite, telegram_user: user, favoritable: record) }

    it { expect { result }.to change { user.favorites.count }.by(-1) }
    it { expect(result[:toast]).to eq("Убрано из избранного") }
    it { expect(result[:inline_keyboard].first.first["text"]).to eq("⭐ В избранное") }
  end

  context "when the user may not use favorites" do
    let(:user) { create(:telegram_user) }

    it { expect { result }.not_to change(Favorite, :count) }
    it { expect(result[:toast]).to eq("Избранное пока недоступно") }
    it { expect(result[:inline_keyboard]).to be_nil }
  end

  context "when the gid cannot be located" do
    before { record.destroy! }

    it { expect { result }.not_to change(Favorite, :count) }
    it { expect(result[:toast]).to eq("Карточка не найдена") }
  end

  context "when no keyboard is supplied" do
    let(:inline_keyboard) { nil }

    it { expect { result }.to change { user.favorites.count }.by(1) }
    it { expect(result[:inline_keyboard]).to be_nil }
  end
end
