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
        @audio_render_manager = AudioRenderManager.new(self)
        @visual_render_manager = VisualRenderManager.new(self)
      end

      #XXX Blank also does not support Effect, it should raise - same with Image and audio effect
      # _track_indexes_ Array of track indexes effect applies to
      def add_audio_effect(audio_effect, track_indexes, in_frame, out_frame)
        @audio_render_manager.add_effect(audio_effect, track_indexes, in_frame, out_frame)
      end

      # _track_indexes_ Array of track indexes effect applies to
      def add_visual_effect(visual_effect, track_indexes, in_frame, out_frame)
        @visual_render_manager.add_effect(visual_effect, track_indexes, in_frame, out_frame)
      end

      def has_effects?
        @audio_render_manager.has_effects? or @visual_render_manager.has_effects?
      end

      # Return an array of Renderers, one for each track
      # Subclasses should override
      def tracks
        @tracks ||= [self].freeze
      end

      def render_audio(context_manager)
        @audio_render_manager.render(context_manager)
      end

      # Subclass should override.
      # Must call acquire_audio_context for every frame content is rendered
      # _render_tracks_ Array of Renderers to render
      def on_render_audio(context_manager, current_frame, render_tracks)
      end

      def render_visual(context_manager)
        @visual_render_manager.render(context_manager)
      end

      # Subclass should override.
      # Must call acquire_visual_context for every frame content is rendered
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