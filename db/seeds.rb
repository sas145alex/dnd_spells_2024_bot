load "db/seeds/seeders/admin_users.rb"
load "db/seeds/seeders/bot_commands.rb"
load "db/seeds/seeders/spells.rb"
load "db/seeds/seeders/creatures.rb"
load "db/seeds/seeders/wild_magics.rb"
load "db/seeds/seeders/feats.rb"
load "db/seeds/seeders/glossary_categories.rb"
load "db/seeds/seeders/glossary_items.rb"
load "db/seeds/seeders/races.rb"
load "db/seeds/seeders/tools.rb"
load "db/seeds/seeders/characteristics.rb"
load "db/seeds/seeders/origins.rb"
load "db/seeds/seeders/character_klasses.rb"
load "db/seeds/seeders/invocations.rb"
load "db/seeds/seeders/metamagics.rb"
load "db/seeds/seeders/maneuvers.rb"
load "db/seeds/seeders/magic_items.rb"

if Rails.env.development? || Rails.env.test?
  pp "Regenerating all searchable columns"
  Multisearchable.regenerate_all_searchable_columns!

  pp "Regenerating all pg multisearch entities"
  Multisearchable.regenerate_all_multisearchables!
end
