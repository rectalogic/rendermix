shared_context 'requires render thread' do
  before(:all) do
    # We can't use rspec mocks in before(:all)
    class MixerMock
      attr_reader :width
      attr_reader :height
      attr_reader :framerate
      def initialize(width, height, framerate)
        @width = width
        @height = height
        @framerate = framerate
      end
    end

    # Subclass MixerApplication to noop some methods.
    # Also make start() wait until render thread is actually started
    class MixerApplicationMock < RenderMix::MixerApplication
      def initialize(mixer)
        super
        @mutex = Mutex.new
        @condvar = ConditionVariable.new
      end
      def simpleInitApp
        @mutex.synchronize { @condvar.signal }
      end
      def simpleUpdate(tpf); end
      def simpleRender(render_manager); end
      def start
        super
        @mutex.synchronize { @condvar.wait(@mutex) }
      end
    end

    @mixer = MixerMock.new(640, 480, Rational(30))
    @app = MixerApplicationMock.new(@mixer)
    @app.start
  end

  def on_render_thread(&block)
    result = @app.enqueue(&block)
    result.get
  end

  after(:all) do
    @app.stop
  end
end
