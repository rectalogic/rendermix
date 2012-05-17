module RenderMix
  module Mix
    class Sequence < Base
      def initialize
        super(0)
        @mix_renderers = []
        @audio_index = 0
        @visual_index = 0
      end

      def append_mix_renderer(mix_renderer)
        @mix_renderers << mix_renderer
        mix_renderer.in_frame = self.duration
        mix_renderer.out_frame = self.duration + mix_renderer.duration - 1
        self.duration += mix_renderer.duration
      end

      def on_render_audio(context_manager, current_frame, tracks)
        #XXX should we zero @mix_renderers if past our duration? same for Parallel - this means we destroy the mix as we proceed, but may be better memory wise - document it in Mixer.mix
        #XXX should Base do this check before calling on_render, and call some destroy method?
        return if current_frame > self.out_frame
        @audio_index = mix_renderer_index(@audio_index, current_frame)
        return unless @audio_index
        @mix_renderers[@audio_index].render_audio(context_manager)
      end

      def on_render_visual(context_manager, current_frame, tracks)
        return if current_frame > self.out_frame
        @visual_index = mix_renderer_index(@visual_index, current_frame)
        return unless @visual_index
        @mix_renderers[@visual_index].render_visual(context_manager)
      end

      def mix_renderer_index(current_index, current_frame)
        mix_renderer = @mix_renderers[current_index]
        return nil if mix_renderer.nil?
        return current_index if mix_renderer.out_frame <= current_frame
        current_index++
      end
      private :mix_renderer_index
    end
  end
end
