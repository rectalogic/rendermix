module RenderMix
  module Effect
    class Base
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

      #XXX need equivalent to Renderer audio_context_released/visual
      #XXX gah, we can't even acquire a context since we aren't a Renderer
      #XXX need to define ContextManager in terms of ContextRenderer
    end
  end
end
