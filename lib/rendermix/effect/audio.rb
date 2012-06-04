# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class Audio < Base
      # @param [Array<Mix::Base>] tracks effect tracks
      def on_rendering_prepare(tracks)
      end

      # @param [AudioContext] audio_context
      # @param [Array<AudioContext>] track_audio_contexts contexts for each track
      # @param [Fixnum] current_frame
      def on_audio_render(audio_context, track_audio_contexts, current_frame)
      end

      def audio_context_released(context)
      end

      def rendering_finished
      end
    end
  end
end
