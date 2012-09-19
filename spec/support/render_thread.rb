shared_context 'requires render thread' do
  before(:all) do

    class MockRenderSystem < RenderMix::MixRenderSystem
      attr_reader :audio_context_manager
      attr_reader :visual_context_manager

      def ruby_initialize(mixer, asset_locations)
        super
        @queue = java.util.concurrent.ConcurrentLinkedQueue.new
      end

      def enqueue(&callable)
        task = RenderMix::Jme::App::AppTask.new(callable)
        @queue.add(task)
        task
      end

      def update
        while (task = @queue.poll) != nil
          task.invoke if not task.isCancelled
        end
      end
    end

    class MockMixer < RenderMix::Mixer
      def create_render_system(asset_locations)
        MockRenderSystem.new(self, asset_locations)
      end
    end

    @mixer = MockMixer.new(640, 480, Rational(30))
    @mixer.render_system.start(RenderMix::Jme::System::JmeContext::Type::OffscreenSurface)
  end

  def on_render_thread(&block)
    result = @mixer.render_system.enqueue(&block)
    result.get
=begin XXX This sometimes rescues 'nil' http://stackoverflow.com/questions/8947954/jruby-makes-rescue-exception-nil-with-rescue-javasystem-out

  rescue java.util.concurrent.ExecutionException => e
    raise e.cause
=end
  end

  after(:all) do
    # Stop and wait for shutdown
    @mixer.render_system.stop(true)
  end
end
