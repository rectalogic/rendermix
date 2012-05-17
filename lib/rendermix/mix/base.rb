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
      # _track_indexes_ Array of track indexes effect applies to
      def add_audio_effect(audio_effect, track_indexes, in_frame, out_frame)
        @audio_effect_manager ||= AudioEffectManager.new(tracks)
        @audio_effect_manager.add_effect(audio_effect, track_indexes, in_frame, out_frame)
      end

      # _track_indexes_ Array of track indexes effect applies to
      def add_visual_effect(visual_effect, track_indexes, in_frame, out_frame)
        @visual_effect_manager ||= VisualEffectManager.new(tracks)
        @visual_effect_manager.add_effect(visual_effect, track_indexes, in_frame, out_frame)
      end

      def has_effects?
        @audio_effect_manager or @visual_effect_manager
      end

      # Return an array of Renderers, one for each track
      # Subclasses should override
      def tracks
        @tracks ||= [self].freeze
      end

      # Subclasses must call acquire_audio_context for every frame
      # they render content
      def render_audio(context_manager)
        return if current_audio_frame > self.out_frame
        renderers = @audio_effect_manager.render(context_manager, @current_audio_frame) if @audio_effect_manager
        renderers ||= tracks
        on_render_audio(context_manager, @current_audio_frame, renderers)
        @current_audio_frame++
      end

      # Subclass should override.
      # _render_tracks_ Array of Renderers to render
      def on_render_audio(context_manager, current_frame, render_tracks)
      end

      # Subclasses must call acquire_visual_context for every frame
      # they render content
      def render_visual(context_manager)
        return if current_visual_frame > self.out_frame
        renderers = @visual_effect_manager.render(context_manager, @current_visual_frame) if @visual_effect_manager
        renderers ||= tracks
        on_render_visual(context_manager, @current_visual_frame, renderers)
        @current_visual_frame++
      end

      # Subclass should override.
      # _render_tracks_ Array of Renderers to render
      def on_render_visual(context_manager, current_frame, render_tracks)
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
