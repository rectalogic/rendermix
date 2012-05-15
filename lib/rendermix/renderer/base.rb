module RenderMix
  module Renderer
    class Base
      attr_reader :frame_number
      attr_reader :frame_in
      attr_reader :frame_out

      def initialize(frame_in, frame_out)
        @frame_in = frame_in
        @frame_out = frame_out
        #XXX subclass should set frame_out based on duration
        # First frame will be 0
        @frame_number = -1
      end

      # Subclasses must call acquire_visual_context or acquire_audio_context
      # for every frame they render content
      def render(render_context)
        @frame_number++
      end

      # Subclasses should override to cleanup any resources they used from render_context
      def audio_context_released
      end
      def visual_context_released
      end
    end
  end
end
