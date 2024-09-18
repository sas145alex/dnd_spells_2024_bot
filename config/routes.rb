Rails.application.routes.draw do
  get "up" => "rails/health#show", :as => :rails_health_check

  devise_for :admin_users, ActiveAdmin::Devise.config

  begin
    ActiveAdmin.routes(self)
  rescue
    ActiveAdmin::DatabaseHitDuringLoad
  end

  # Render dynamic PWA files from app/views/pwa/*
  # get "service-worker" => "rails/pwa#service_worker", :as => :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", :as => :pwa_manifest

  telegram_webhook TelegramController
end
