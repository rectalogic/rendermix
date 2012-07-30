# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class Base
      include FrameTime

      # @return [Mixer]
      attr_reader :mixer
      # @return [Fixnum] starting frame of this effect in parents timeline
      attr_reader :in_frame
      # @return [Fixnum] ending frame of this effect in parents timeline
      attr_reader :out_frame
      attr_reader :duration
      attr_reader :current_frame

      def initialize
        @current_frame = 0
      end

      # @param [Mixer] mixer
      # @param [Array<Mix::Base>] tracks array of mix elements this effect applies to
      def apply(mixer, tracks, in_frame, out_frame)
        raise(InvalidMixError, 'Effect already applied') if @mixer
        @mixer = mixer
        @tracks = tracks.freeze
        @in_frame = in_frame
        @out_frame = out_frame
        @duration = out_frame - in_frame + 1
      end

      def current_time
        frame_to_time(current_frame, duration)
      end

      def rendering_prepare(context_manager)
        # Clone context manager for each track
        @context_managers = Array.new(@tracks.length)
        @context_managers.fill { context_manager.clone }
        on_rendering_prepare(context_manager, @tracks)
      end

      # Acquires the effects context, and renders effect tracks into their
      # context managers.
      # Yields the effects acquired context, and an array of contexts
      # for each track.
      # @yieldparam [AudioContext, VisualContext] context
      # @yieldparam [Array<AudioContext>, Array<VisualContext>] current_contexts
      def render(context_manager)
        # Acquire context first, before rendering tracks.
        # So if any track was using this context, it will lose it first.
        context = context_manager.acquire_context(self)
        # Render each track into its context manager
        current_contexts = @context_managers.each_with_index.collect do |cm, i|
          cm.render(@tracks[i])
          # Propagate antialias request
          context_manager.request_antialias if cm.reset_antialias
          cm.current_context
        end
        yield context, current_contexts
        @current_frame += 1
      end
      protected :render

      def rendering_finished
        @context_managers.each do |context_manager|
          context_manager.release_context
        end
        @context_managers = nil
        on_rendering_finished
      end
    end
  end
end
