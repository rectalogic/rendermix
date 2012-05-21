module RenderMix
  module Mix
    class Media < Base
      def initialize(mixer, filename, start_frame=0, duration=nil)
        #XXX init rawmedia decoder using mixer.rawmedia_session and use duration if none specified
        super(mixer, duration)
      end

      def on_render_audio(context_manager, current_frame, renderer_tracks)
        #XXX acquire if we have audio
        #XXXaudio_context = context_manager.acquire_context(self)
      end

      def audio_context_released(context)
        #XXX cleanup any context specific state
      end

      def audio_rendering_finished
        #XXX
      end

      def on_render_visual(context_manager, current_frame, renderer_tracks)
        #XXX acquire if we have video
        #XXXvisual_context = context_manager.acquire_context(self)
      end

      def visual_context_released(context)
        #XXX cleanup any context specific state
      end

      def visual_rendering_finished
        #XXX drop any textures etc.
      end
    end
  end
end
