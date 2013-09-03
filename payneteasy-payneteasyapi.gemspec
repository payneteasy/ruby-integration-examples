Gem::Specification.new do |s|
  s.name                  = 'payneteasy-payneteasyapi'
  s.version               = '0.1.0'
  s.summary               = 'Ruby library for PaynetEasy payment API.'
  s.author                = 'Artem Ponomarenko'
  s.email                 = 'imenem@inbox.ru'
  s.require_paths         = ['lib', 'lib/paynet_easy/paynet_easy_api']

  s.files                 = Dir['lib/**/*.rb']
  s.test_files            = Dir['test/**/*_test.rb']

  s.required_ruby_version = '>= 1.9.3'
  s.add_development_dependency 'test-unit'
end