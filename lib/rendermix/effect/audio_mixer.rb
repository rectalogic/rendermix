# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class AudioMixer < AudioBase
      def on_rendering_prepare(context_manager)
        @audio_mixer = mixer.rawmedia_session.create_audio_mixer
        @audio_context = AudioContext.new(mixer)
      end

      def on_audio_render(context_manager, track_audio_contexts)
        context_manager.context = @audio_context
        buffers = track_audio_contexts.collect do |context|
          context.buffer if context
        end
        @audio_mixer.mix(buffers, @audio_context.buffer)
      end

      def on_rendering_finished
        @audio_mixer = nil
        @audio_context = nil
      end
    end
  end
end
