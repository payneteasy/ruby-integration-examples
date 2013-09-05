Gem::Specification.new do |s|
  s.name                  = 'payneteasy-payneteasyapi'
  s.version               = '0.9.0'
  s.summary               = 'Ruby library for PaynetEasy payment API.'
  s.author                = 'Artem Ponomarenko'
  s.email                 = 'imenem@inbox.ru'
  s.homepage              = 'https://github.com/payneteasy/ruby-library-payneteasy-api'
  s.require_paths         = %w(lib lib/paynet_easy/paynet_easy_api)

  s.files                 = Dir['lib/**/*.rb'] + %w(.gemtest Gemfile Gemfile.lock Rakefile payneteasy-payneteasyapi.gemspec)
  s.test_files            = Dir['test/**/*.rb']
  s.extra_rdoc_files      = Dir['example/**/*.rb'] + Dir['doc/**/*.md'] << 'README.md'

  s.required_ruby_version = '>= 1.9.3'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'rake'
end