require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = %{--color --format progress}
end
task :spec => [Fixtures::VIDEO_320x240_30fps, Fixtures::IMAGE_640x480]
