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
        raise(InvalidMixError, 'Duration not specified') unless duration
        @duration = duration
        @audio_render_manager = AudioRenderManager.new(self)
        @visual_render_manager = VisualRenderManager.new(self)
      end

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

      # Subclass can override
      #def audio_rendering_prepare(context_manager)

      # Subclass should override.
      # Must call acquire_audio_context for every frame content is rendered
      # _render_tracks_ Array of Renderers to render
      def on_render_audio(context_manager, current_frame, render_tracks)
      end

      # Subclasses can override to cleanup state when rendering complete.
      #def audio_rendering_finished

      # Subclasses can override to cleanup any context specific state.
      # Rendering is not yet complete at this point.
      # def audio_context_released(context)

      # Subclass can override
      #def visual_rendering_prepare(context_manager)

      def render_visual(context_manager)
        @visual_render_manager.render(context_manager)
      end

      # Subclass should override.
      # Must call acquire_visual_context for every frame content is rendered
      # _render_tracks_ Array of Renderers to render
      def on_render_visual(context_manager, current_frame, render_tracks)
      end

      # Subclasses can override to cleanup state when rendering complete.
      #def visual_rendering_finished

      # Subclasses can override to cleanup any context specific state.
      # Rendering is not yet complete at this point.
      # def visual_context_released(context)
    end
  end
end
