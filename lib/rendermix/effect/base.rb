module RenderMix
  module Effect
    class Base
      include Renderer

      # Beginning and ending frames of this effect
      attr_reader :in_frame
      attr_reader :out_frame
      # Array of Renderers this Effect processes
      attr_reader :tracks

      # _effect_delegate_ AudioEffect or VisualEffect
      # _tracks_ Array of renderers this Effect applies to
      def initialize(effect_delegate, tracks, in_frame, out_frame)
        #XXX deal with effect_delegate
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
      end
      
      #XXX Clone context for each track
      def audio_rendering_prepare(context_manager)
      end

      def render_audio(context_manager)
        #XXX
        #XXX render our context for each track
      end

      def audio_context_released(context)
        #XXX
      end

      def audio_rendering_finished
        #XXX
      end

      #XXX Clone context for each track
      def visual_rendering_prepare(context_manager)
      end

      def render_visual(context_manager)
        #XXX
      end

      def visual_context_released(context)
        #XXX
      end

      def visual_rendering_finished
        #XXX
      end
    end
  end
end
