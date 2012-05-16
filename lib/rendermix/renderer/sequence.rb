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

      def render_audio(context_manager)
        super
      end

      def render_visual(context_manager)
        super
        #XXX render current renderer, pop if finished - figure out effect handling first (audio and video) - for all renderers
        #XXX audio and visual effects can overlap, need to render both and then render all remaining tracks

        #XXX also panzoom (via UV)
      end
    end
  end
end
