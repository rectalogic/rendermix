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
        not @effect_manager.nil?
      end

      def render(context_manager)
        return if current_frame > @mix.out_frame
        if @effect_manager
          renderers = @effect_manager.render(context_manager, @current_frame)
        end
        renderers ||= tracks
        on_render(context_manager, @current_frame, renderers)
        @current_frame++
#XXX this won't work - Sequence is its own track, and so Effect on Sequence would render itself (which has an effect...) and recurse
#XXX same problem for Media with Effect
#XXX do we need 2 stage render? render effects then content? and ContextManager does this
#XXX could we set a flag in here, so on the effect reentrant render we skip effects - will that work for Parallel too?

#XXX maybe Parallel should be special - only multitrack case, so move tracks stuff down into it and simplify Sequence/Media etc.
      end
    end

    class AudioRenderManager < RenderManager
      def create_effect_manager
        AudioEffectManager.new(mix.tracks)
      end

      def on_render(context_manager, current_frame, renderers)
        mix.on_render_audio(context_manager, current_frame, renderers)
      end
    end

    class VisualRenderManager < RenderManager
      def create_effect_manager
        VisualEffectManager.new(mix.tracks)
      end

      def on_render(context_manager, current_frame, renderers)
        mix.on_render_visual(context_manager, current_frame, renderers)
      end
    end
  end
end
