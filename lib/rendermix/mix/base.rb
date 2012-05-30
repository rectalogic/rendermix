module RenderMix
  module Mix
    class Base
      # @return [Mixer] parent mixer
      attr_reader :mixer

      # Beginning and ending frames of this renderer in parents timeline
      attr_accessor :in_frame
      attr_accessor :out_frame

      attr_accessor :duration

      def initialize(mixer, duration)
        raise(InvalidMixError, 'Duration not specified') unless duration
        @mixer = mixer
        @duration = duration
        @audio_render_manager = AudioRenderManager.new(self)
        @visual_render_manager = VisualRenderManager.new(self)
      end

      # @param [Effect::Audio] audio_effect
      # @param [Array<Fixnum>] track_indexes array of track indexes effect applies to
      def add_audio_effect(audio_effect, track_indexes, in_frame, out_frame)
        @audio_render_manager.add_effect(audio_effect, track_indexes, in_frame, out_frame)
      end

      # @param [Effect::Visual] visual_effect
      # @param [Array<Fixnum>] track_indexes array of track indexes effect applies to
      def add_visual_effect(visual_effect, track_indexes, in_frame, out_frame)
        @visual_render_manager.add_effect(visual_effect, track_indexes, in_frame, out_frame)
      end

      def has_effects?
        @audio_render_manager.has_effects? or @visual_render_manager.has_effects?
      end

      # Subclasses may override
      # @return [Array<Mix::Base>] array of Mix elements, one for each track
      def tracks
        @tracks ||= [self].freeze
      end

      def render_audio(context_manager)
        @audio_render_manager.render(context_manager)
      end

      # Prepare for rendering audio. Called once before first call to #render_audio
      # Subclass can implement.
      # @param [AudioContextManager] context_manager
      def audio_rendering_prepare(context_manager)
      end

      # Subclass should override to render audio.
      # Must call ContextManager#acquire_audio_context from this method
      # for every frame audio is rendered.
      # @param [AudioContextManager] context_manager
      # @param [Array<Mix::Base>] render_tracks Array of Mix elements to render
      def on_render_audio(context_manager, current_frame, render_tracks)
      end

      # Called when audio rendering is finished,
      # #render_audio will not be called again.
      # Subclasses can override to cleanup state when rendering complete.
      def audio_rendering_finished
      end

      # Subclasses can override to release any context specific data,
      # or revert any context changes made when context initially acquired.
      # Rendering is not yet complete at this point.
      # @param [AudioContext] context
      def audio_context_released(context)
      end

      # Prepare for rendering visual. Called once before first call to #render_visual
      # Subclass can implement.
      # @param [VisualContextManager] context_manager
      def visual_rendering_prepare(context_manager)
      end

      def render_visual(context_manager)
        @visual_render_manager.render(context_manager)
      end

      # Subclass should override to render visual.
      # Must call ContextManager#acquire_visual_context from this method
      # for every frame visual is rendered.
      # @param [VisualContextManager] context_manager
      # @param [Array<Mix::Base>] render_tracks Array of Mix elements to render
      def on_render_visual(context_manager, current_frame, render_tracks)
      end

      # Called when audio rendering is finished,
      # #render_audio will not be called again.
      # Subclasses can override to cleanup state when rendering complete.
      def visual_rendering_finished
      end

      # Subclasses can override to release any context specific data,
      # or revert any context changes made when context initially acquired.
      # Rendering is not yet complete at this point.
      # @param [VisualContext] context
      def visual_context_released(context)
      end
    end
  end
end
