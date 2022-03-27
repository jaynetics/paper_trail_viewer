require 'paper_trail'

require_relative 'paper_trail_viewer/data_source/base'
require_relative 'paper_trail_viewer/data_source/active_record'
require_relative 'paper_trail_viewer/data_source/bigquery'
require_relative 'paper_trail_viewer/engine'
require_relative 'paper_trail_viewer/query'
require_relative 'paper_trail_viewer/rollback'
require_relative 'paper_trail_viewer/version'

module PaperTrailViewer
  mattr_accessor(:allow_rollback)   { true }
  mattr_accessor(:data_source)      { DataSource::ActiveRecord.new }
  mattr_accessor(:user_path_method) { :user_path }
end
