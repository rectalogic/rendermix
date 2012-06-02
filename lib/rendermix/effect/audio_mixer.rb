module RenderMix
  module Effect
    class AudioMixer < Audio
      def on_rendering_prepare(tracks)
        @audio_mixer = mixer.rawmedia_session.create_audio_mixer
      end

      def on_audio_render(audio_context, track_audio_contexts, current_frame)
        buffers = track_audio_contexts.collect do |context|
          context.buffer if context
        end
        @audio_mixer.mix(buffers, audio_context.buffer)
      end

      def rendering_finished
        @audio_mixer = nil
      end
    end
  end
end
