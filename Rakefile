require 'rake'
require 'bundler/gem_tasks'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new
task default: [:compile_js, :generate_spec_app, :spec]

task :compile_js do
  sh 'npm run compile'
end

task :generate_spec_app do
  sh 'rm -rf spec/dummy'
  sh *%w[
    rails new spec/dummy
    --template=spec/app_template.rb
    --skip-action-cable
    --skip-action-mailbox
    --skip-action-mailer
    --skip-action-text
    --skip-active-job
    --skip-active-storage
    --skip-asset-pipeline
    --skip-bootsnap
    --skip-bundle
    --skip-git
    --skip-hotwire
    --skip-javascript
    --skip-jbuilder
    --skip-keeps
    --skip-listen
    --skip-spring
    --skip-sprockets
    --skip-system-test
    --skip-test
    --skip-turbolinks
    --skip-webpack
  ]
end

# ensure fresh js is compiled when packaging the gem
task build: [:compile_js]
