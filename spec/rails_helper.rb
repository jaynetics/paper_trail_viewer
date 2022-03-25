ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'

require 'selenium/webdriver'
require 'webdrivers/chromedriver'

Capybara.server = :puma, { Silent: true }

Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
