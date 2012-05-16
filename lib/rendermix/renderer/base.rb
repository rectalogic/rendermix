module RenderMix
  module Renderer
    #XXX can we do some common Effect handling in this base class?
    class Base
      # Current frame being rendered
      attr_reader :current_frame

      # Beginning and ending frames of this renderer in parents timeline
      attr_accessor :in_frame
      attr_accessor :out_frame

      attr_accessor :duration

      def initialize(duration)
        @duration = duration
        # First frame will be 0
        @current_frame = -1
      end

      # Subclasses must call acquire_visual_context or acquire_audio_context
      # for every frame they render content
      def render(render_context)
        @current_frame++
        #XXX make this method dispatch to do_render or something
      end

      # Subclasses should override to cleanup any resources they used from render_context
      def audio_context_released
      end

      def visual_context_released
      end
    end
  end
end
