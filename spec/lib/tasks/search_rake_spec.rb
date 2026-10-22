require "rails_helper"
require "rake"

RSpec.describe "rake search:reindex" do
  subject(:run_task) { Rake::Task["search:reindex"].execute }

  let!(:spell) { create(:spell, title: "Огнённый шар", original_title: "Fireball") }

  before(:context) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("search:reindex")
  end

  before do
    allow($stdout).to receive(:puts)
    spell.update_column(:searchable_title, "")
    PgSearch::Document.delete_all
  end

  it "rebuilds searchable_title" do
    expect { run_task }.to change { spell.reload.searchable_title }.to("огненный шар fireball")
  end

  it "rebuilds the pg_search documents from the rebuilt column" do
    run_task

    expect(PgSearch::Document.where(searchable: spell).pluck(:content)).to eq(["огненный шар fireball"])
  end
end
