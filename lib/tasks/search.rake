namespace :search do
  desc "Rebuild searchable_title columns and pg_search documents for every Multisearchable model"
  task reindex: :environment do
    # used_klasses scans ApplicationRecord.descendants, and rake doesn't eager-load (rake_eager_load is
    # off) — without this a model nothing has autoloaded yet would be silently skipped.
    Rails.application.eager_load!
    puts "Reindexing #{Multisearchable.used_klasses.map(&:name).sort.join(', ')} (#{Rails.env})"
    Multisearchable.reindex!
    puts "Done: #{PgSearch::Document.count} search documents"
  end
end
