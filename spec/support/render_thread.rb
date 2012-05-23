shared_context 'requires render thread' do
  before(:all) do
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

    # We can't use rspec mocks in before(:all)
    @mixer = MixerMock.new(640, 480, Rational(30))
    @app = RenderMix::MixerApplication.new(@mixer)
    def @app.simpleInitApp
    end
    def @app.simpleUpdate(tpf)
    end
    def @app.simpleRender(render_manager)
    end
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
