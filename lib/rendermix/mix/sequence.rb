# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Sequence < Base
      # @param [Mixer] mixer
      # @param [Array<Mix::Base>] mix_elements
      def initialize(mixer, mix_elements)
        duration = 0
        mix_elements.each do |mix_element|
          mix_element.validate(mixer)
          mix_element.in_frame = duration
          mix_element.out_frame = duration + mix_element.duration - 1
          duration += mix_element.duration
        end
        super(mixer, duration)
        @audio_mix_elements = mix_elements.dup
        @visual_mix_elements = mix_elements.dup
      end

      def on_audio_render(context_manager, current_frame)
        audio_mix_element = current_mix_element(@audio_mix_elements, current_frame)
        return unless audio_mix_element
        audio_mix_element.audio_render(context_manager)
      end

      def audio_rendering_finished
        audio_mix_element = @audio_mix_elements.first
        audio_mix_element.audio_rendering_finished if audio_mix_element
        @audio_mix_elements.clear
      end

      def on_visual_render(context_manager, current_frame)
        visual_mix_element = current_mix_element(@visual_mix_elements, current_frame)
        return unless visual_mix_element
        visual_mix_element.visual_render(context_manager)
      end

      def visual_rendering_finished
        visual_mix_element = @visual_mix_elements.first
        visual_mix_element.visual_rendering_finished if visual_mix_element
        @visual_mix_elements.clear
      end

      def current_mix_element(mix_elements, current_frame)
        mix = mix_elements.first
        return nil if mix.nil?
        if mix.in_frame <= current_frame and mix.out_frame >= current_frame
          return mix
        else
          mix_elements.shift
          return mix_elements.first
        end
      end
      private :current_mix_element
    end
  end
end
