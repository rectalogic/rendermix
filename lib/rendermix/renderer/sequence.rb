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

      def render(render_context)
        super
        #XXX render current renderer, pop if finished - figure out effect handling first (audio and video) - for all renderers
        #XXX also panzoom (via UV)
      end
    end
  end
end
