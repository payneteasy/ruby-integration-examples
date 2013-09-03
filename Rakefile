require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/paynet_easy/paynet_easy_api'
  t.test_files = Dir['test/**/*_test.rb']
end