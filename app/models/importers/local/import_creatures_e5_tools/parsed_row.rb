class Importers::Local::ImportCreaturesE5Tools
  class ParsedRow < ApplicationOperation
    def initialize(row)
      @row = row
    end

    def title
      "title"
    end

    def original_title
      row[:name].strip
    end

    def description
      "description"
    end

    def original_description
      text = <<~TEXT.chomp
        **#{original_title}**
        *#{row[:size]} #{row[:type]}, #{row[:alignment]}*

        **AC** #{armor_class}
        **Initiative** #{modificator(row[:dexterity])} (#{row[:dexterity]})
        **HP** #{hit_points_formula}
        **Speed** #{row[:speed]}

        Ability - Value - Modificator - Saving Modificator
        STR #{row[:strength]} #{modificator(row[:strength])} #{saving_modificator(row[:strength], "STR")}
        DEX #{row[:dexterity]} #{modificator(row[:dexterity])} #{saving_modificator(row[:dexterity], "DEX")}
        CON #{row[:constitution]} #{modificator(row[:constitution])} #{saving_modificator(row[:constitution], "CON")}
        INT #{row[:intelligence]} #{modificator(row[:intelligence])} #{saving_modificator(row[:intelligence], "INT")}
        WIS #{row[:wisdom]} #{modificator(row[:wisdom])} #{saving_modificator(row[:wisdom], "WIS")}
        CHA #{row[:charisma]} #{modificator(row[:charisma])} #{saving_modificator(row[:charisma], "CHA")}

        #{text_block_for("Vulnerabilities", row[:damage_vulnerabilities], inline: true)}
        #{text_block_for("Resistances", row[:damage_resistances], inline: true)}
        #{text_block_for("Damage Immunities", row[:damage_immunities], inline: true)}
        #{text_block_for("Condition Immunities", row[:condition_immunities], inline: true)}
        **Skills** #{row[:skills]}
        **Senses** #{row[:senses]}
        **Languages** #{row[:languages]}
        **CR** #{row[:cr]}

        #{text_block_for("Traits", row[:traits])}
        #{text_block_for("Actions", row[:actions])}
        #{text_block_for("Bonus Actions", row[:bonus_actions])}
        #{text_block_for("Reactions", row[:reactions])}
        #{text_block_for("Legendary Actions", row[:legendary_actions])}
        #{text_block_for("Mythic Actions", row[:mythic_actions])}
        #{text_block_for("Lair Actions", row[:lair_actions])}
        #{text_block_for("Regional Effects", row[:regional_effects])}
        #{text_block_for("Habitat", row[:environment], inline: true)}
        #{text_block_for("Treasure", row[:treasure], inline: true)}
      TEXT

      text.chomp.gsub(/\n{3,}/, "\n\n")
    end

    def edition_source
      row[:source].upcase.delete("'")
    end

    def creature_size
      valid_values = Creature.creature_sizes.keys.map(&:to_sym)
      formatted_value = row[:size].downcase.to_sym
      formatted_value.in?(valid_values) ? formatted_value : :vary
    end

    def creature_type
      raw_value = row[:type].downcase.strip
      if raw_value.include?(",") || ["or"].in?(raw_value.split)
        :vary
      elsif raw_value.include?("swarm of") && raw_value.include?("(")
        # "swarm of Small Fiends (Demon)"
        raw_value.split[0..-2].last.singularize.to_sym
      elsif raw_value.include?("swarm of")
        # "swarm of Tiny Beasts"
        raw_value.split.last.singularize.to_sym
      else
        # бывает типы вида "dragon (chromatic)"
        raw_value.split.first.to_sym
      end
    end

    def creature_subtype
      raw_value = row[:type].downcase.strip
      if raw_value.include?("swarm of")
        nil
      else
        formatted_subtype = raw_value.split[1..].join(" ").delete("(").delete(")")
        formatted_subtype.presence
      end
    end

    def armor_class
      row[:ac].to_i
    end

    def hit_points
      row[:hp].split.first.to_i
    end

    def hit_points_formula
      row[:hp]
    end

    def challenge_rating
      text = row[:cr]
      if text.include?("/")
        num, den = text.split("/").map(&:to_f)
        den.zero? ? Float::NAN : num / den
      else
        text.to_f
      end
    end

    def import_source
      "https://5e.tools/bestiary.html"
    end

    private

    attr_reader :row

    def modificator(value)
      ((value.to_i - 10) / 2).floor
    end

    def saving_modificator(value, skill)
      saving_throws_modificators[skill] || modificator(value)
    end

    def saving_throws_modificators
      @saving_throws_modificators ||=
        row[:saving_throws]
          .split(",").map(&:strip).map(&:upcase)
          .map { it.split(" ") }
          .to_h
          .transform_values(&:to_i)
    end

    def text_block_for(block_title, block_text, inline: false)
      formatted_text = format_long_text(block_text)
      return if formatted_text.blank?

      if inline
        "**#{block_title}** #{block_text}"
      else
        "**#{block_title}**\n#{formatted_text}\n"
      end
    end

    def format_long_text(text)
      return nil if text.blank?

      all_groups = text.split("\n").map(&:strip)
      bolded_groups = all_groups.map do |group_text|
        group_name = group_text.split(".").first
        group_description = group_text.split(".")[1..]
        ["**#{group_name}**", group_description].join(".")
      end.join("\n")

      bolded_groups
        .gsub(/:(?<word>\w+)/, ":\n\\k<word>")
        .gsub(/(?<word>\p{Alpha}{2,}+)(?<number>\d+)/, "\\k<word>\n\\k<number>")
        .gsub(/(?<word1>\p{Lower}+)(?<word2>\p{Upper})/, "\\k<word1>\n\\k<word2>")
    end
  end
end
