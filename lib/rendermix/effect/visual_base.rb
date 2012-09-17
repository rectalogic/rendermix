# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class VisualBase < Base
      include TextTexture

      # @param [VisualContextManager] context_manager
      def on_rendering_prepare(context_manager)
      end

      def visual_render(context_manager)
        render(context_manager) do |context, track_contexts|
          on_visual_render(context_manager, context, track_contexts)
        end
      end

      # @param [VisualContextManager] context_manager
      # @param [VisualContext] visual_context
      # @param [Array<VisualContext>] track_visual_contexts contexts for each track
      def on_visual_render(context_manager, visual_context, track_visual_contexts)
      end

      def on_rendering_finished
      end
    end
  end
end
