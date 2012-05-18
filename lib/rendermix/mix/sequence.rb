module RenderMix
  module Mix
    class Sequence < Base
      def initialize
        super(0)
        @audio_renderers = []
        @visual_renderers = []
      end

      def append(mix_renderer)
        raise(RuntimeError, 'Sequence cannot be modified after Effects applied') if has_effects?
        @audio_renderers << mix_renderer
        @visual_renderers << mix_renderer
        mix_renderer.in_frame = self.duration
        mix_renderer.out_frame = self.duration + mix_renderer.duration - 1
        self.duration += mix_renderer.duration
      end

      def on_render_audio(context_manager, current_frame, renderer_tracks)
        audio_renderer = current_mix_renderer(@audio_renderers, current_frame)
        return unless audio_renderer
        audio_renderer.render_audio(context_manager)
      end

      def audio_rendering_complete
        audio_renderer = @audio_renderers.first
        audio_renderer.audio_rendering_complete if audio_renderer
        @audio_renderers.clear
      end

      def on_render_visual(context_manager, current_frame, renderer_tracks)
        visual_renderer = current_mix_renderer(@visual_renderers, current_frame)
        return unless visual_renderer
        visual_renderer.render_visual(context_manager)
      end

      def visual_rendering_complete
        visual_renderer = @visual_renderers.first
        visual_renderer.visual_rendering_complete if visual_renderer
        @visual_renderers.clear
      end

      def current_mix_renderer(mix_renderers, current_frame)
        mix_renderer = mix_renderers.first
        return nil if mix_renderer.nil?
        if mix_renderer.out_frame <= current_frame
          return mix_renderer
        else
          mix_renderers.shift
        end
      end
      private :current_mix_renderer
    end
  end
end
