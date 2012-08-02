require 'rawmedia/rake/video_fixture_task'
require_relative '../rendermix/rake/image_fixture_task'

module Fixtures
  DIR = File.expand_path('../../../spec/fixtures', __FILE__)
  VIDEO_320x240_30fps = File.join(DIR, '320x240-30fps.mov')
  IMAGE_640x480 = File.join(DIR, '640x480.png')
end

RawMedia::Rake::VideoFixtureTask.new(Fixtures::VIDEO_320x240_30fps) do |task|
  task.framerate = '30'
  task.size = '320x240'
end

RenderMix::Rake::ImageFixtureTask.new(Fixtures::IMAGE_640x480) do |task|
  task.width = 640
  task.height = 480
end

desc "Generate all media fixtures"
task :fixtures => [Fixtures::VIDEO_320x240_30fps, Fixtures::IMAGE_640x480]
