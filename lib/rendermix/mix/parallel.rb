module RenderMix
  module Mix
    class Parallel < Base
      def initialize(mixer)
        super(mixer, 0)
        @mix_renderers = []
      end

      def add_track(mix_renderer)
        raise(RuntimeError, 'Parallel cannot be modified after Effects applied') if has_effects?
        raise(InvalidMixError, 'Renderer does not belong to this Mixer') if mix_renderer.mixer != self.mixer
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

      def audio_rendering_finished
        @mix_renderers.each do |renderer|
          renderer.audio_rendering_finished
        end
        @mix_renderers.clear if @rendering_finished
        @rendering_finished = true
      end

      def on_render_visual(context_manager, current_frame, render_tracks)
        render_tracks.each do |track|
          track.render_visual(context_manager)
        end
      end

      def visual_rendering_finished
        @mix_renderers.each do |renderer|
          renderer.visual_rendering_finished
        end
        @mix_renderers.clear if @rendering_finished
        @rendering_finished = true
      end
    end
  end
end
