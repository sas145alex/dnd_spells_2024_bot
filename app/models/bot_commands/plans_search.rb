module BotCommands
  class PlansSearch < BaseCommand
    def call
      if input_value.blank?
        provide_plans
      elsif plan_selected?
        provide_plan_description
      else
        invalid_input
      end
    end

    def initialize(input_value: nil, user: nil)
      @input_value = input_value
      @user = user
    end

    private

    attr_reader :input_value

    def provide_plans
      text = "Выбери"
      variants = plan_scope
      options = keyboard_options(variants)
      inline_keyboard = options.in_groups_of(2, false)
      inline_keyboard.append([go_back_button])
      reply_markup = {inline_keyboard: inline_keyboard}

      {
        text: text,
        reply_markup: reply_markup,
        parse_mode: parse_mode
      }
    end

    def provide_plan_description
      Presenters::LeafCard.call(object: selected_object, user: user)
    end

    def plan_selected?
      selected_object.is_a?(::Plan)
    end

    def plan_scope
      ::Plan.published.ordered.all.map(&:decorate)
    end

    def callback_prefix
      "plans"
    end
  end
end
