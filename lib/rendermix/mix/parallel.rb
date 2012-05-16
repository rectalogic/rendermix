module RenderMix
  module Mix
    class Parallel < Base
      def initialize
        super(0)
        @renderers = []
      end

      def append_renderer(renderer)
        @renderers << renderer
        renderer.in_frame = 0
        renderer.out_frame = renderer.duration - 1
        if renderer.duration > self.duration
          self.duration = renderer.duration
        end
      end

      def track_count#XXX
        @renderers.length
      end

    end
  end
end
