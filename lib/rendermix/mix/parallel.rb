module RenderMix
  module Mix
    class Parallel < Base
      def initialize(mixer)
        super(mixer, 0)
        @mix_elements = []
      end

      def append(mix_element)
        raise(RuntimeError, 'Parallel cannot be modified after Effects applied') if has_effects?
        mix_element.add(mixer)
        @mix_elements << mix_element
        mix_element.in_frame = 0
        mix_element.out_frame = mix_element.duration - 1
        if mix_element.duration > self.duration
          self.duration = mix_element.duration
        end
      end

      def tracks
        @tracks ||= @mix_elements.dup.freeze
      end

      def on_audio_render(context_manager, current_frame, render_tracks)
        render_tracks.each do |track|
          track.audio_render(context_manager)
        end
      end

      def audio_rendering_finished
        @mix_elements.each do |renderer|
          renderer.audio_rendering_finished
        end
        @mix_elements.clear if @rendering_finished
        @rendering_finished = true
      end

      def on_visual_render(context_manager, current_frame, render_tracks)
        render_tracks.each do |track|
          track.visual_render(context_manager)
        end
      end

      def visual_rendering_finished
        @mix_elements.each do |renderer|
          renderer.visual_rendering_finished
        end
        @mix_elements.clear if @rendering_finished
        @rendering_finished = true
      end
    end
  end
end
