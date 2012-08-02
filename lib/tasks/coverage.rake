require 'rspec/core/rake_task'

# simplecov doesn't work right with jruby https://github.com/colszowka/simplecov/issues/86
# rcov 1.0 doesn't work with jruby https://github.com/relevance/rcov/issues/90
# rcov 0.9.11 does, but not in 1.9 mode
desc 'Run RSpec code examples with simplecov'
RSpec::Core::RakeTask.new(:coverage) do |task|
  task.rcov = true
  task.rcov_path = 'rspec'
  task.rcov_opts = '--require simplecov_start'
end
task :coverage => [PKG, Fixtures::VIDEO_320x240_30fps, Fixtures::IMAGE_640x480]
