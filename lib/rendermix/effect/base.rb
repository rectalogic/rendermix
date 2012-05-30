module RenderMix
  module Effect
    class Base
      # Beginning and ending frames of this effect
      attr_reader :in_frame
      attr_reader :out_frame

      # @return [Array<Mix::Base>] array of mix tracks this Effect processes
      attr_reader :tracks

      # @param [Audio, Video] effect_delegate
      # @param [Array<Mix::Base>] tracks array of mix elements this effect applies to
      def initialize(effect_delegate, tracks, in_frame, out_frame)
        #XXX deal with effect_delegate
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
      end
      
      #XXX Clone context for each track
      def rendering_prepare(context_manager)
      end

      def render(context_manager)
        #XXX
        #XXX render our context for each track
      end

      def context_released(context)
        #XXX
      end

      def rendering_finished
        #XXX
      end
    end
  end
end
