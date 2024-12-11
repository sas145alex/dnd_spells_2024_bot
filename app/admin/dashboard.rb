# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "row" do
      div class: "col-sm-6" do
        panel "Most requested spells" do
          i = 0
          table_for Spell.order(requested_count: :desc).limit(10) do |t|
            t.column :index do
              i += 1
            end
            t.column :title do |spell|
              link_to(spell.title, admin_spell_path(spell))
            end
            t.column :requested_count
          end
        end
      end

      div class: "col-sm-6" do
        panel "Users statistic" do
          ol do
            li "Пользователей всего: #{TelegramUser.count}"
            li "Пользователей с 10+ комманд: #{TelegramUser.where("command_requested_count >= ?", 10).count}"
            li "Пользователей с 50+ комманд: #{TelegramUser.where("command_requested_count >= ?", 50).count}"
            li "Пользователей с 100+ комманд: #{TelegramUser.where("command_requested_count >= ?", 100).count}"
            li "Пользователей активных за последние 2 недели: #{TelegramUser.where("last_seen_at >= ?", 2.weeks.ago).count}"
          end
        end
      end

      div class: "col-sm-6" do
        panel "Recent users" do
          table_for TelegramUser.order(last_seen_at: :desc).limit(10) do |t|
            t.column :id do |user|
              user.external_id
            end
            t.column :chat_id
            t.column :username
            t.column "Last Seen At (UTC)", :last_seen_at
            t.column :command_requested_count
          end
        end
      end
    end
  end
end
