namespace :handoff do
  desc "Export the public site as a static HTML/CSS/JS bundle (handoff zip)"
  task export: :environment do
    require Rails.root.join("lib/handoff_exporter")
    HandoffExporter.new.call
  end
end
