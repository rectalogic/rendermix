# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class VisualBase < Base
      # @param [VisualContextManager] context_manager
      # @param [Array<Mix::Base>] tracks effect tracks
      def on_rendering_prepare(context_manager, tracks)
      end

      def visual_render(context_manager)
        render(context_manager) do |context, track_contexts|
          on_visual_render(context, track_contexts)
        end
      end

      # @param [VisualContext] visual_context
      # @param [Array<VisualContext>] track_visual_contexts contexts for each track
      def on_visual_render(visual_context, track_visual_contexts)
      end

      def visual_context_released(context)
      end

      def on_rendering_finished
      end
    end
  end
end
