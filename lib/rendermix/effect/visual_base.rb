# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class VisualBase < Base
      def initialize
        @current_frame = 0
      end

      # @param [VisualContextManager] context_manager
      # @param [Array<Mix::Base>] tracks effect tracks
      def on_rendering_prepare(context_manager, tracks)
      end

      def visual_render(context_manager)
        context, track_contexts = render(context_manager)
        on_visual_render(context, track_contexts, @current_frame)
        @current_frame += 1
      end

      # @param [VisualContext] visual_context
      # @param [Array<VisualContext>] track_visual_contexts contexts for each track
      # @param [Fixnum] current_frame
      def on_visual_render(visual_context, track_visual_contexts, current_frame)
      end

      def visual_context_released(context)
      end

      def rendering_finished
      end
    end
  end
end
