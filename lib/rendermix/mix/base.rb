# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Base
      include FrameTime

      # @return [Mixer] parent mixer
      attr_reader :mixer

      # @return [Fixnum] starting frame of this element in parents timeline
      attr_accessor :in_frame
      # @return [Fixnum] ending frame of this element in parents timeline
      attr_accessor :out_frame
      # @return [Fixnum] total duration in frames of this element in parents timeline
      attr_reader :duration

      def initialize(mixer, duration=0)
        @mixer = mixer
        @duration = duration
        @audio_render_manager = AudioRenderManager.new(self)
        @visual_render_manager = VisualRenderManager.new(self)
      end

      def validate(mixer)
        raise(InvalidMixError, 'Mix element does not belong to this Mixer') if mixer != self.mixer
        raise(InvalidMixError, 'Mix element already added') if in_frame || out_frame
      end

      # @param [Effect::Audio] audio_effect
      def apply_audio_effect(audio_effect, in_frame, out_frame)
        @audio_render_manager.apply_effect(audio_effect, in_frame, out_frame)
      end

      # @param [Effect::Visual] visual_effect
      def apply_visual_effect(visual_effect, in_frame, out_frame)
        @visual_render_manager.apply_effect(visual_effect, in_frame, out_frame)
      end

      def has_effects?
        @audio_render_manager.has_effects? or @visual_render_manager.has_effects?
      end

      # Subclasses may override
      # @return [Array<Mix::Base>] array of Mix elements, one for each track
      def tracks
        @tracks ||= [self].freeze
      end

      # Prepare for rendering audio. Called once before first call to #audio_render
      # Subclass can implement.
      # @param [AudioContextManager] context_manager
      def audio_rendering_prepare(context_manager)
      end

      # @return false if rendering finished
      def audio_render(context_manager)
        @audio_render_manager.render(context_manager)
      end

      # Subclass should override to render audio.
      # Must call AudioContextManager#acquire_context from this method
      # for every frame audio is rendered.
      # @param [AudioContextManager] context_manager
      def on_audio_render(context_manager, current_frame)
      end

      # Called when audio rendering is finished,
      # #audio_render will not be called again.
      # Subclasses can override to cleanup state when rendering complete.
      def audio_rendering_finished
      end

      # Prepare for rendering visual. Called once before first call to #visual_render
      # Subclass can implement.
      # @param [VisualContextManager] context_manager
      def visual_rendering_prepare(context_manager)
      end

      # @return false if rendering finished
      def visual_render(context_manager)
        @visual_render_manager.render(context_manager)
      end

      # Subclass should override to render visual.
      # Must call VisualContextManager#acquire_context from this method
      # for every frame visual is rendered.
      # @param [VisualContextManager] context_manager
      def on_visual_render(context_manager, current_frame)
      end

      # Called when visual rendering is finished,
      # #visual_render will not be called again.
      # Subclasses can override to cleanup state when rendering complete.
      def visual_rendering_finished
      end
    end
  end
end
