require_relative '../lib/rendermix'

require_relative 'sample_media'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.expect_with :rspec
end

# Configure root logger to log to a file
RenderMix::JavaLog::LogManager.getLogManager().reset
handler = RenderMix::JavaLog::FileHandler.new(File.expand_path("../../log/test.log", __FILE__))
handler.formatter = RenderMix::JavaLog::SimpleFormatter.new
RenderMix::JavaLog::Logger.getLogger('').addHandler(handler)

FIXTURES = File.expand_path('../fixtures', __FILE__)
FIXTURE_IMAGE = File.join(SAMPLE_MEDIA, '640x480.png')
FIXTURE_MEDIA = File.join(SAMPLE_MEDIA, 'red-4x3.mov')

# Must be called from on_render_thread
def register_test_assets
  @mixer.render_system.asset_manager.registerLocator(File.join(FIXTURES, 'assets'),
                                                     RenderMix::Jme::Asset::Plugins::FileLocator.java_class)
end
