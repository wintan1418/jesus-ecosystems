source "https://rubygems.org"

# ─── Core ─────────────────────────────────────────────────────────────────────
gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"

# ─── Hotwire stack (importmap, no Node build) ─────────────────────────────────
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.0"

gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]

# ─── Rails 8 Solid stack ──────────────────────────────────────────────────────
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

# ─── Active Storage + Cloudflare R2 (S3-compatible) ───────────────────────────
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", require: false

# ─── Auth / authorization ─────────────────────────────────────────────────────
gem "devise"
gem "pundit"

# ─── Content / models ─────────────────────────────────────────────────────────
gem "friendly_id", "~> 5.5"
gem "acts_as_list"
gem "view_component"

# ─── i18n ─────────────────────────────────────────────────────────────────────
gem "rails-i18n"

# ─── Admin / notifications ────────────────────────────────────────────────────
gem "avo", ">= 3.2"
gem "noticed"

# ─── SEO / analytics ──────────────────────────────────────────────────────────
gem "meta-tags"
gem "sitemap_generator"
gem "ahoy_matey"

# ─── Email / spam / rate limit ────────────────────────────────────────────────
gem "resend"
gem "rack-attack"

# ─── Schema annotations ───────────────────────────────────────────────────────
gem "annotaterb", group: :development

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "shoulda-matchers", "~> 6.0"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
end
