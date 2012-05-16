module RenderMix
  module Renderer
    #XXX can we do some common Effect handling in this base class?
    #XXX yes, support adding audio/visual effects, do insertion sort into arrays the subclass can access

    class Base
      # Current frame being rendered
      attr_reader :current_audio_frame
      attr_reader :current_visual_frame

      # Beginning and ending frames of this renderer in parents timeline
      attr_accessor :in_frame
      attr_accessor :out_frame

      attr_accessor :duration

      def initialize(duration)
        @duration = duration
        # First frame will be 0
        @current_audio_frame = -1
        @current_visual_frame = -1
      end

      # Subclasses must call acquire_audio_context for every frame
      # they render content
      def render_audio(context_manager)
        @current_audio_frame++

      end

      # Subclasses must call acquire_visual_context for every frame
      # they render content
      def render_visual(context_manager)
        @current_visual_frame++
        #XXX make this method dispatch to on_render or something
      end

      # Subclasses should override to release any references they have
      # to anything in the context
      def audio_context_released
      end
      def visual_context_released
      end
    end
  end
end
