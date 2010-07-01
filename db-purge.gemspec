Gem::Specification.new do |spec|
  spec.name           = 'db-purge'
  spec.version        = `git describe`.strip.split('-').first
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]
  spec.homepage       = "http://github.com/stocksoftware/db-purge"
  spec.summary        = "ActiveRecord plugin to purge the database prior to tests"
  spec.description    = <<-TEXT
Clean the database prior to tests with db-purge.
  TEXT
  spec.files          = Dir['{lib}/**/*', '*.gemspec'] +
                        ['Rakefile']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = false
end
