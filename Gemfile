source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'application_insights', '~> 0.5.6'
gem 'dotenv-rails', groups: [:development, :test] # this has to be here because of load order

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.5'
gem 'sentry-rails', '~> 5.8'
# Use postgresql as the database for Active Record
gem 'i18n', '>= 1.10'
gem 'parser', '>= 3.1.2.0'
gem 'pg', '~> 1.2'
gem 'rack-host-redirect'
gem 'rails-i18n', '~> 7.0.3'

# Azure key vault secrets to ENV variables
gem 'azure_env_secrets', github: 'ministryofjustice/azure_env_secrets', tag: 'v0.1.3'
gem 'hwf_hmrc_api', github: 'hmcts/hwf_hmrc_api', tag: 'v0.2.6'

# configuration
gem 'config'
# speed up start
gem 'bootsnap', require: false

# authentication
gem 'devise', '>= 4.9.2'
gem 'devise_invitable', '>= 2.0.8'
gem 'devise-security', '~> 0.18.0'

# authorisation
gem 'pundit', '~> 2.1'

# background jobs and scheduling
gem 'delayed_cron_job'
gem 'delayed_job_active_record'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 4.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1', group: :doc

# template language
gem 'logstasher', git: 'https://github.com/shadabahmed/logstasher.git',
                  ref: '0b80e972753ba7ef36854b48d2c371e32963bc8d'
gem 'slim-rails', '~> 3.2'

gem 'puma', '~> 6.3', '>= 6.0.2'

# Date validation
gem 'date_validator', '0.12'
gem 'will_paginate'

# Soft deletion
gem "paranoia"

# tracking model changes
gem "paper_trail"

# encrypting stored data
gem 'simple_encryptable'

# Google tag Manager
gem 'gtm_on_rails'

gem 'chartkick', '~> 4.1.3'
gem 'ckeditor', '~> 5.1'
gem 'groupdate'
gem 'nokogiri'
gem 'pg_search'
gem 'rest-client'
gem 'rubyzip'
gem 'virtus'

# GovUK Notify
gem 'govuk_notify_rails'

group :development do
  # speed up local development via livereload
  # gem 'guard-livereload'
  gem 'rack-livereload'
  gem 'terminal-notifier-guard'
  gem 'web-console'
end

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'byebug'
  gem 'climate_control'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen'
  gem 'parallel_tests'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'timecop'
end

group :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'brakeman'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'codeclimate-test-reporter', require: nil
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
  gem 'faker'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'site_prism'
  gem "test-prof", "~> 1.0"
  gem 'webdrivers'
  gem 'webmock'
end
