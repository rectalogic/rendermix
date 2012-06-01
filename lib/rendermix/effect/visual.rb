module RenderMix
  module Effect
    class Visual < Base
      # @param [Array<Mix::Base>] tracks effect tracks
      def on_rendering_prepare(tracks)
      end

      # @param [VisualContext] visual_context
      # @param [Array<VisualContext>] track_visual_contexts contexts for each track
      # @param [Fixnum] current_frame
      def on_visual_render(visual_context, track_visual_contexts, current_frame)
        #XXX can use current_frame / duration for percentage progress
      end

      def visual_context_released(context)
      end

      def rendering_finished
      end
    end
  end
end
