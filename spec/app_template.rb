gem 'paper_trail_viewer', path: __dir__ + '/../'

generate 'paper_trail:install'
generate 'resource', 'entity name:string status:string --no-test-framework'
generate 'resource', 'platform name:string status:string --no-test-framework'

model_body = <<-RUBY
  has_paper_trail

  validates_presence_of :name
  validates_presence_of :status
RUBY

inject_into_class 'app/models/entity.rb', 'Entity', model_body
inject_into_class 'app/models/platform.rb', 'Platform', model_body

route 'mount PaperTrailViewer::Engine => "/changes"'

rake 'db:migrate db:test:prepare'
