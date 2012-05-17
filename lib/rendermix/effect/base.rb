module RenderMix
  module Effect
    class Base
      include Renderer

      # Beginning and ending frames of this effect
      attr_reader :in_frame
      attr_reader :out_frame
      # Array of Renderers this Effect processes
      attr_reader :tracks

      #XXX pass in tracks array - gah, will need access to the renderer itself so we can render it's tracks - so hand in Renderer and we can query it for tracks - and it needs a get_renderer(track) method? watch out for recursion...
      # _effect_delegate_ AudioEffect or VisualEffect
      # _tracks_ Array of renderers this Effect applies to
      def initialize(effect_delegate, tracks, in_frame, out_frame)
        #XXX deal with effect_delegate
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
      end
      
      #XXX called once from Renderer before Effect is about to be rendered
      #XXX need to clone context for each track we have
      def prepare_context(context_manager)
      end

      def render_audio(context_manager)
        #XXX
        #XXX render our context for each track
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
