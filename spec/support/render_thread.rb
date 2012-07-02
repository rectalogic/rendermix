shared_context 'requires render thread' do
  before(:all) do
    # We can't use rspec mocks in before(:all)

    # Subclass MixerApplication to noop some methods.
    # Also make start() wait until render thread is actually started
    class MixerApplicationMock < RenderMix::MixerApplication
      attr_reader :mixer
      attr_reader :root_visual_context
      attr_reader :visual_context_manager
      attr_reader :root_audio_context
      attr_reader :audio_context_manager

      def initialize(mixer, asset_locations)
        super
      end
      def simpleInitApp
        super
        @mutex.synchronize { @condvar.signal }
      end
      def simpleUpdate(tpf); end
      def simpleRender(render_manager); end
      def start
        super(RenderMix::Jme::System::JmeContext::Type::OffscreenSurface)
        @mutex.synchronize { @condvar.wait(@mutex) }
      end
      def shutdown
        @mutex.synchronize do
          stop
          @condvar.wait(@mutex)
        end
      end
    end

    class MixerMock < RenderMix::Mixer
      attr_reader :app
      attr_reader :tpf
      def initialize(width, height, framerate)
        super
        @tpf = framerate.denominator / framerate.numerator.to_f
        @app = create_mixer_application
      end
      def create_mixer_application
        MixerApplicationMock.new(self, @asset_locations)
      end
    end

    mixer = MixerMock.new(640, 480, Rational(30))
    @app = mixer.app
    @app.start
  end

  def on_render_thread(&block)
    result = @app.enqueue(&block)
    result.get
=begin XXX This sometimes rescues 'nil' http://stackoverflow.com/questions/8947954/jruby-makes-rescue-exception-nil-with-rescue-javasystem-out

  rescue java.util.concurrent.ExecutionException => e
    raise e.cause
=end
  end

  after(:all) do
    # Stop and wait for the app to finish
    @app.shutdown
  end
end
