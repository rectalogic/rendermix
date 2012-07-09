# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Parallel < Base
      # @param [Mixer] mixer
      # @param [Array<Mix::Base>] mix_elements
      def initialize(mixer, mix_elements)
        duration = 0
        mix_elements.each do |mix_element|
          mix_element.validate(mixer)
          mix_element.in_frame = 0
          mix_element.out_frame = mix_element.duration - 1
          duration = mix_element.duration if mix_element.duration > duration
        end
        super(mixer, duration)
        @mix_elements = mix_elements.dup
      end

      def tracks
        @tracks ||= @mix_elements.dup.freeze
      end

      def on_audio_render(context_manager, current_frame)
        @mix_elements.each do |track|
          track.audio_render(context_manager)
        end
      end

      def audio_rendering_finished
        @mix_elements.each do |renderer|
          renderer.audio_rendering_finished
        end
        @mix_elements.clear if @rendering_finished
        @rendering_finished = true
      end

      def on_visual_render(context_manager, current_frame)
        @mix_elements.each do |track|
          track.visual_render(context_manager)
        end
      end

      def visual_rendering_finished
        @mix_elements.each do |renderer|
          renderer.visual_rendering_finished
        end
        @mix_elements.clear if @rendering_finished
        @rendering_finished = true
      end
    end
  end
end
