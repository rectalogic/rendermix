# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class AudioMixer < AudioBase
      def on_rendering_prepare(context_manager)
        @audio_mixer = mixer.rawmedia_session.create_audio_mixer
        @audio_buffer = AudioBuffer.new(mixer)
      end

      def on_audio_render(audio_context, track_audio_contexts)
        audio_context.audio_buffer = @audio_buffer
        buffers = track_audio_contexts.collect do |context|
          context.audio_buffer.buffer if context && context.audio_buffer
        end
        @audio_mixer.mix(buffers, audio_context.audio_buffer.buffer)
      end

      def on_rendering_finished
        @audio_mixer = nil
        @audio_buffer = nil
      end
    end
  end
end
