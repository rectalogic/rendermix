module RenderMix
  module Effect
    class Base
      include Renderer

      # Beginning and ending frames of this effect in renderers timeline
      attr_reader :in_frame
      attr_reader :out_frame

      def initialize(in_frame, out_frame)
        @in_frame = in_frame
        @out_frame = out_frame
      end
      
      #XXX called once from Renderer before Effect is about to be rendered
      #XXX need to clone context for each track we have
      def prepare_context_manager(context_manager)
      end

      def render_audio(context_manager)
        #XXX
      end

      def audio_context_released
        #XXX
      end

      def render_visual(context_manager)
        #XXX
      end

      def visual_context_released
        #XXX
      end
    end
  end
end
