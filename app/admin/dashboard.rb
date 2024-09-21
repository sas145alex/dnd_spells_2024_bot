# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "row" do
      div class: "col-sm-6" do
        panel "Most requested spells" do
          table_for Spell.order(requested_count: :desc).limit(10) do |t|
            t.column :title do |spell|
              link_to(spell.title, admin_spell_path(spell))
            end
            t.column :requested_count
          end
        end
      end

      div class: "col-sm-6" do
        panel "Recent users" do
          table_for TelegramUser.order(last_seen_at: :desc).limit(10) do |t|
            t.column :id do |user|
              user.external_id
            end
            t.column :username
            t.column :last_seen_at
            t.column :spells_requested_count
          end
        end
      end
    end
  end
end
