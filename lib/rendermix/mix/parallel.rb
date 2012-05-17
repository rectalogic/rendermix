module RenderMix
  module Mix
    class Parallel < Base
      def initialize
        super(0)
        @mix_renderers = []
      end

      def append_mix_renderer(mix_renderer)
        @mix_renderers << mix_renderer
        mix_renderer.in_frame = 0
        mix_renderer.out_frame = mix_renderer.duration - 1
        if mix_renderer.duration > self.duration
          self.duration = mix_renderer.duration
        end
      end

      def track_count
        @mix_renderers.length
      end

      def on_render_audio(context_manager, current_frame, tracks)
        return if current_frame > self.out_frame
        tracks.each do |track|
          @mix_renderers[track].render_audio(context_manager)
        end
      end

      def on_render_visual(context_manager, current_frame, tracks)
        return if current_frame > self.out_frame
        tracks.each do |track|
          @mix_renderers[track].render_visual(context_manager)
        end
      end
    end
  end
end
