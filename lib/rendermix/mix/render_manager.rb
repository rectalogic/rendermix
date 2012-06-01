module RenderMix
  module Mix
    class RenderManager
      # @return [Mix::Base] mix_element
      attr_reader :mix_element
      protected :mix_element

      # @param [Mix::Base] mix_element
      def initialize(mix_element)
        @mix_element = mix_element
        @current_frame = 0
      end

      # @param [Effect::Audio, Effect::Visual] effect the type of the
      #  effect depends on the type of the RenderManager
      def apply_effect(effect, track_indexes, in_frame, out_frame)
        if in_frame < 0 || in_frame >= @mix_element.duration ||
            out_frame < in_frame || out_frame >= @mix_element.duration
          raise InvalidMixError, "Effect frame range (#{in_frame}..#{out_frame}) is invalid"
        end
        @effect_manager ||= EffectManager.new(@mix_element)
        @effect_manager.apply_effect(effect, track_indexes, in_frame, out_frame)
      end

      def has_effects?
        !!@effect_manager
      end

      # @param [AudioContextManager, VisualContextManager] context_manager
      def render(context_manager)
        if @current_frame == 0
          rendering_prepare(context_manager)
        elsif @current_frame >= @mix_element.duration
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
        renderers ||= @mix_element.tracks
        on_render(context_manager, @current_frame, renderers) unless renderers.empty?
        @current_frame += 1
      end
    end

    class AudioRenderManager < RenderManager
      def rendering_prepare(context_manager)
        mix_element.audio_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame, renderers)
        mix_element.on_audio_render(context_manager, current_frame, renderers)
      end

      def rendering_finished
        mix_element.audio_rendering_finished
      end
    end

    class VisualRenderManager < RenderManager
      def rendering_prepare(context_manager)
        mix_element.visual_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame, renderers)
        mix_element.on_visual_render(context_manager, current_frame, renderers)
      end

      def rendering_finished
        mix_element.visual_rendering_finished
      end
    end
  end
end
