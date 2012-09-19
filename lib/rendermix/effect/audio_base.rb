# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class AudioBase < Base
      # @param [AudioContextManager] context_manager
      def on_rendering_prepare(context_manager)
      end

      def audio_render(context_manager)
        render(context_manager) do |track_contexts|
          on_audio_render(context_manager, track_contexts)
        end
      end

      # @param [AudioContextManager] context_manager
      # @param [Array<AudioContext>] track_audio_contexts contexts for each track
      def on_audio_render(context_manager, track_audio_contexts)
      end

      def on_rendering_finished
      end
    end
  end
end
