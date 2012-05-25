module RenderMix
  module Mix
    class RenderManager
      attr_reader :mix_renderer
      private :mix_renderer

      def initialize(mix_renderer)
        @mix_renderer = mix_renderer
        @current_frame = 0
      end

      def add_effect(effect_delegate, track_indexes, in_frame, out_frame)
        @effect_manager ||= create_effect_manager
        @effect_manager.add_effect(effect_delegate, track_indexes, in_frame, out_frame)
      end

      def has_effects?
        !!@effect_manager
      end

      def render(context_manager)
        if @current_frame == 0
          rendering_prepare(context_manager)
        elsif @current_frame >= @mix_renderer.duration
          rendering_finished
          return
        end

        if @effect_manager and not @skip_effects
          # In the case where the mix is its own track (Sequence, Media etc.),
          # we need to guard against reentrant rendering. The Effect may
          # render us, and we don't want to render the Effect again when it does.
          @skip_effects = true
          renderers = @effect_manager.render(context_manager, @current_frame)
          @skip_effects = nil
        end
        renderers ||= @mix_renderer.tracks
        on_render(context_manager, @current_frame, renderers) unless renderers.empty?
        @current_frame += 1
      end
    end

    class AudioRenderManager < RenderManager
      def create_effect_manager
        AudioEffectManager.new(mix_renderer.tracks)
      end

      def rendering_prepare(context_manager)
        mix_renderer.audio_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame, renderers)
        mix_renderer.on_render_audio(context_manager, current_frame, renderers)
      end

      def rendering_finished
        mix_renderer.audio_rendering_finished
      end
    end

    class VisualRenderManager < RenderManager
      def create_effect_manager
        VisualEffectManager.new(mix_renderer.tracks)
      end

      def rendering_prepare(context_manager)
        mix_renderer.visual_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame, renderers)
        mix_renderer.on_render_visual(context_manager, current_frame, renderers)
      end

      def rendering_finished
        mix_renderer.visual_rendering_finished
      end
    end
  end
end
