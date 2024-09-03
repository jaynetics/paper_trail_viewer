ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'

require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.server = :puma, { Silent: true }

Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1600, 900] do |opts|
      # https://github.com/SeleniumHQ/selenium/issues/14453
      opts.add_argument('--disable-search-engine-choice-screen')
      # various fixes for GH actions
      opts.add_argument('--disable-dev-shm-usage')
      opts.add_argument('--disable-extensions')
      opts.add_argument('--disable-site-isolation-trials')
      opts.add_argument('--remote-debugging-pipe')
    end
  end
end
