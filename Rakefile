#require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test)
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

desc 'Run RSpec code examples with simplecov'
RSpec::Core::RakeTask.new(:coverage) do |task|
  task.rcov = true
  task.rcov_path = 'rspec'
  task.rcov_opts = '--require simplecov_start'
end
