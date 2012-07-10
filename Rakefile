# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test)
require 'rspec/core/rake_task'
require 'rawmedia/rake/video_fixture_task'
require 'rendermix/rake/image_fixture_task'
require 'yard'
require 'kramdown'

fixture_video_320x240_30fps = 'spec/fixtures/320x240-30fps.mov'
fixture_image_640x480 = 'spec/fixtures/640x480.png'

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = %{--color --format progress}
end
task :spec => [fixture_video_320x240_30fps, fixture_image_640x480]

# simplecov doesn't work right with jruby https://github.com/colszowka/simplecov/issues/86
# rcov 1.0 doesn't work with jruby https://github.com/relevance/rcov/issues/90
# rcov 0.9.11 does, but not in 1.9 mode
desc 'Run RSpec code examples with simplecov'
RSpec::Core::RakeTask.new(:coverage) do |task|
  task.rcov = true
  task.rcov_path = 'rspec'
  task.rcov_opts = '--require simplecov_start'
end
task :coverage => [fixture_video_320x240_30fps, fixture_image_640x480]

YARD::Rake::YardocTask.new

directory 'spec/fixtures'

RawMedia::Rake::VideoFixtureTask.new(fixture_video_320x240_30fps) do |task|
  task.framerate = '30'
  task.size = '320x240'
end
task fixture_video_320x240_30fps => 'spec/fixtures'

RenderMix::Rake::ImageFixtureTask.new(fixture_image_640x480) do |task|
  task.width = 640
  task.height = 480
end
task fixture_image_640x480 => 'spec/fixtures'

desc "Generate all media fixtures"
task :fixtures => [fixture_video_320x240_30fps, fixture_image_640x480]

