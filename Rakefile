require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.libs << 'features'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# feature test send requests to cs and
# require real cs username and password
Rake::TestTask.new(:features) do |test|
  test.libs << 'lib' << 'test' << 'features'
  test.pattern = 'features/**/*.rb'
  test.verbose = true
end

task test_all: [:test, :features]

task default: :test
