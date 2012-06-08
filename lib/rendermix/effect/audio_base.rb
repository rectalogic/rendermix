# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class AudioBase < Base
      def initialize
        @current_frame = 0
      end

      # @param [AudioContextManager] context_manager
      # @param [Array<Mix::Base>] tracks effect tracks
      def on_rendering_prepare(context_manager, tracks)
      end

      def audio_render(context_manager)
        context, track_contexts = render(context_manager)
        on_audio_render(context, track_contexts, @current_frame)
        @current_frame += 1
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
