module RenderMix
  module Mix
    #XXX can we do some common Effect handling in this base class?
    #XXX yes, support adding audio/visual effects, do insertion sort into arrays the subclass can access

    class Base
      include AudioRenderer
      include VisualRenderer

      # Current frame being rendered
      attr_reader :current_audio_frame
      attr_reader :current_visual_frame

      # Beginning and ending frames of this renderer in parents timeline
      attr_accessor :in_frame
      attr_accessor :out_frame

      attr_accessor :duration

      def initialize(duration)
        @duration = duration
        @current_audio_frame = 0
        @current_visual_frame = 0
      end

      #XXX Blank also does not support Effect, it should raise - same with Image and audio effect
      def add_audio_effect(effect, in_frame, out_frame)
      end

      def add_visual_effect(effect, in_frame, out_frame)
      end

      def track_count#XXX
        1
      end

      # Subclasses must call acquire_audio_context for every frame
      # they render content
      def render_audio(context_manager)
        #XXX invoke on_render_audio
        @current_audio_frame++
      end

      # Subclasses must call acquire_visual_context for every frame
      # they render content
      def render_visual(context_manager)
        @current_visual_frame++
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
