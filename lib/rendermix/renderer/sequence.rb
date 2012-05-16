module RenderMix
  module Renderer
    class Sequence < Base
      def initialize
        super(0)
        @renderers = []
      end

      def append_renderer(renderer)
        @renderers << renderer
        renderer.in_frame = self.duration
        renderer.out_frame = self.duration + renderer.duration - 1
        self.duration += renderer.duration
      end

    end
  end
end
