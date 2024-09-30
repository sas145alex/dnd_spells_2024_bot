RSpec.describe Spell do
  describe ".search_by_title" do
    subject { described_class.search_by_title(search_input) }

    let_it_be(:spell_random, freeze: true) do
      create(:spell, title: "Случайный", original_title: "random")
    end

    let_it_be(:spell_smite_1, freeze: true) do
      create(:spell, title: "Палящая кара", original_title: "Searing Smite")
    end
    let_it_be(:spell_smite_2, freeze: true) do
      create(:spell, title: "Оглушающая кара", original_title: "Staggering Smite")
    end

    let_it_be(:spell_aura_1, freeze: true) do
      create(:spell, title: "Аура святости", original_title: "Holy Aura")
    end
    let_it_be(:spell_aura_2, freeze: true) do
      create(:spell, title: "Аура жизни", original_title: "Aura of Life")
    end

    let_it_be(:spell_food, freeze: true) do
      create(:spell, title: "Сотворение пищи и воды", original_title: "Create Food and Water")
    end

    let_it_be(:spell_fly_1, freeze: true) do
      create(:spell, title: "Полет", original_title: "Fly")
    end
    let_it_be(:spell_fly_2_strange_russian_symbol, freeze: true) do
      create(:spell, title: "Полёт", original_title: "Fly Russian")
    end

    let_it_be(:spell_black_tentacles, freeze: true) do
      create(:spell, title: "Эвардовы чёрные щупальца", original_title: "Evard's Black Tentacles")
    end

    context "locale ru" do
      context "when looking for a smite" do
        let(:search_input) { "кара" }

        it { is_expected.to contain_exactly(spell_smite_1, spell_smite_2) }
      end

      context "when looking for a aura" do
        let(:search_input) { "аура" }

        it { is_expected.to contain_exactly(spell_aura_1, spell_aura_2) }
      end

      context "when looking for a food" do
        let(:search_input) { "пища" }

        it { is_expected.to contain_exactly(spell_food) }
      end

      context "when looking for a fly" do
        let(:search_input) { "черные" }

        it { is_expected.to contain_exactly(spell_black_tentacles) }

        context "with strange symbol" do
          let(:search_input) { "чёрные" }

          it { is_expected.to contain_exactly(spell_black_tentacles) }
        end
      end

      context "when looking for a tentacles" do
        let(:search_input) { "tentacl" }

        it { is_expected.to contain_exactly(spell_black_tentacles) }
      end
    end

    context "locale en" do
      context "when looking for a smite" do
        let(:search_input) { "smite" }

        it { is_expected.to contain_exactly(spell_smite_1, spell_smite_2) }
      end

      context "when looking for a aura" do
        let(:search_input) { "aura" }

        it { is_expected.to contain_exactly(spell_aura_1, spell_aura_2) }
      end

      context "when looking for a food" do
        let(:search_input) { "food" }

        it { is_expected.to contain_exactly(spell_food) }
      end

      context "when looking for a fly" do
        let(:search_input) { "fly" }

        it { is_expected.to contain_exactly(spell_fly_1, spell_fly_2_strange_russian_symbol) }
      end

      context "when looking for a tentacles" do
        let(:search_input) { "tentacl" }

        it { is_expected.to contain_exactly(spell_black_tentacles) }
      end
    end
  end
end
