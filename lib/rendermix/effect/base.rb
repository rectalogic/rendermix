# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class Base
      # @return [Mixer]
      attr_reader :mixer
      # @return [Fixnum] starting frame of this effect in parents timeline
      attr_reader :in_frame
      # @return [Fixnum] ending frame of this effect in parents timeline
      attr_reader :out_frame
      attr_reader :duration

      # @param [Mixer] mixer
      # @param [Array<Mix::Base>] tracks array of mix elements this effect applies to
      def apply(mixer, tracks, in_frame, out_frame)
        raise(InvalidMixError, 'Effect already applied') if @mixer
        @mixer = mixer
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
        @duration = out_frame - in_frame + 1
        @current_frame = 0
      end

      def rendering_prepare(context_manager)
        # Clone context manager for each track
        @context_managers = Array.new(@tracks.length)
        @context_managers.fill { context_manager.clone }
        on_rendering_prepare(@tracks)
      end

      # Acquires the effects context, and renders effect tracks into their
      # context managers.
      # Returns the effects acquired context, and an array of contexts
      # for each track.
      # @return [VisualContext, Array<VisualContext>] if context_manager is VisualContextManager
      # @return [AudioContext, Array<AudioContext>] if context_manager is AudioContextManager
      def render(context_manager)
        # Render each track into its context manager
        current_contexts = @context_managers.each_with_index.collect do |cm, i|
          cm.render(@tracks[i])
          cm.current_context
        end
        return context_manager.acquire_context(self), current_contexts
      end
      private :render

      # Either this or #visual_render will be called, not both
      def audio_render(context_manager)
        context, track_contexts = render(context_manager)
        on_audio_render(context, track_contexts, @current_frame)
        @current_frame += 1
      end

      # Either this or #audio_render will be called, not both
      def visual_render(context_manager)
        context, track_contexts = render(context_manager)
        on_visual_render(context, track_contexts, @current_frame)
        @current_frame += 1
      end
    end
  end
end
