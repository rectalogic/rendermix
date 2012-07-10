# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

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
      def apply_effect(effect, in_frame, out_frame)
        if in_frame < 0 || in_frame >= @mix_element.duration ||
            out_frame < in_frame || out_frame >= @mix_element.duration
          raise InvalidMixError, "Effect frame range (#{in_frame}..#{out_frame}) is invalid"
        end
        @effect_manager ||= EffectManager.new(@mix_element)
        @effect_manager.apply_effect(effect, in_frame, out_frame)
      end

      def has_effects?
        !!@effect_manager
      end

      # @param [AudioContextManager, VisualContextManager] context_manager
      def render(context_manager)
        return if @current_frame > @mix_element.duration

        if not @rendering_effect
          rendering_prepare(context_manager) if @current_frame == 0

          # Set a flag so we can detect when we are reentrantly rendering
          # (the case where the mix element is its own track
          # (Sequence, Media etc.)
          # The Effect will render us and we don't want to render the Effect
          # again when it does.
          if @effect_manager
            @rendering_effect = true
            effect_rendered = @effect_manager.render(context_manager, @current_frame)
            @rendering_effect = nil
          end

          if @current_frame == @mix_element.duration
            rendering_finished
            return
          end
        end

        # Do not render if we just rendered an effect on ourself
        on_render(context_manager, @current_frame) unless effect_rendered

        # Do not increment frame when rendering an effect
        @current_frame += 1 unless @rendering_effect
      end
    end

    class AudioRenderManager < RenderManager
      def rendering_prepare(context_manager)
        mix_element.audio_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame)
        mix_element.on_audio_render(context_manager, current_frame)
      end

      def rendering_finished
        mix_element.audio_rendering_finished
      end
    end

    class VisualRenderManager < RenderManager
      def rendering_prepare(context_manager)
        mix_element.visual_rendering_prepare(context_manager)
      end

      def on_render(context_manager, current_frame)
        mix_element.on_visual_render(context_manager, current_frame)
      end

      def rendering_finished
        mix_element.visual_rendering_finished
      end
    end
  end
end
