module RenderMix
  module Mix
    class Parallel < Base
      def initialize
        super(0)
        @mix_renderers = []
      end

      def add_track(mix_renderer)
        raise(InvalidMixError, 'Parallel cannot be modified after Effects applied') if has_effects?
        @mix_renderers << mix_renderer
        mix_renderer.in_frame = 0
        mix_renderer.out_frame = mix_renderer.duration - 1
        if mix_renderer.duration > self.duration
          self.duration = mix_renderer.duration
        end
      end

      def tracks
        @tracks ||= @mix_renderers.dup.freeze
      end

      def on_render_audio(context_manager, current_frame, render_tracks)
        render_tracks.each do |track|
          track.render_audio(context_manager)
        end
      end

      def on_render_visual(context_manager, current_frame, render_tracks)
        render_tracks.each do |track|
          track.render_visual(context_manager)
        end
      end
    end
  end
end
