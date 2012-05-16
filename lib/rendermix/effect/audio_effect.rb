module RenderMix
  module Effect
    class AudioEffect < Base
      include AudioRenderer

      def render_audio(context_manager)
        #XXX
      end

      def audio_context_released
        #XXX
      end
    end
  end
end
