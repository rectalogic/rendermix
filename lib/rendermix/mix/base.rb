module RenderMix
  module Mix
    #XXX can we do some common Effect handling in this base class?
    #XXX yes, support adding audio/visual effects, do insertion sort into arrays the subclass can access

    class Base
      include Renderer

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
        @audio_effects ||= []
        #XXX insertion sort - should effect be Effect::Base or an AudioEffect, and so should tracks be in Base already or passed to this method and we build Base and set AudioEffect on it?
      end

      def add_visual_effect(effect, in_frame, out_frame)
        @visual_effects ||= []
        #XXX see add_audio_effect comments
      end

      def track_count
        1
      end

      # Subclasses must call acquire_audio_context for every frame
      # they render content
      def render_audio(context_manager)
        #XXX get active effect if there is one, if not then pop a new one if active, and prepare it
        #XXX render effect if we now have one - Effect can expose tracks it renders
        #XXX call on_render_audio with remaining tracks to be rendered (if any)
        #XXX the only reason to render the remaining tracks is to validate they *don't* render - can we simplify? when we setup a new Effect, we can compute remaining tracks and cache

        if @audio_effects
          #XXX see above
        end
        #XXX invoke on_render_audio
        on_render_audio(context_manager, @current_audio_frame, XXXtracks)
        @current_audio_frame++
      end
      def on_render_audio(context_manager, current_frame, tracks)
      end

      # Subclasses must call acquire_visual_context for every frame
      # they render content
      def render_visual(context_manager)
        @current_visual_frame++
      end
      def on_render_visual(context_manager, current_frame, tracks)
      end

      # Subclasses should override to release any references they have
      # to anything in the context
      #XXX these are defined by Renderer module, don't need to declare
      def audio_context_released
      end
      def visual_context_released
      end
    end
  end
end
