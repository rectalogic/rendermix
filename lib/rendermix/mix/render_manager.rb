module RenderMix
  module Mix
    class RenderManager
      attr_reader :mix

      def initialize(mix)
        @mix = mix
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
        if @current_frame > @mix.out_frame
          rendering_complete
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
        renderers ||= @mix.tracks
        on_render(context_manager, @current_frame, renderers) unless renderers.empty?
        @current_frame += 1
      end
    end

    class AudioRenderManager < RenderManager
      def create_effect_manager
        AudioEffectManager.new(mix.tracks)
      end

      def on_render(context_manager, current_frame, renderers)
        mix.on_render_audio(context_manager, current_frame, renderers)
      end

      def rendering_complete
        mix.audio_rendering_complete
      end
    end

    class VisualRenderManager < RenderManager
      def create_effect_manager
        VisualEffectManager.new(mix.tracks)
      end

      def on_render(context_manager, current_frame, renderers)
        mix.on_render_visual(context_manager, current_frame, renderers)
      end

      def rendering_complete
        mix.visual_rendering_complete
      end
    end
  end
end
