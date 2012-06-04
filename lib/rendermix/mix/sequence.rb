# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Sequence < Base
      # @param [Mixer] mixer
      def initialize(mixer)
        super(mixer, 0)
        @audio_mix_elements = []
        @visual_mix_elements = []
      end

      # @param [Mix::Base] mix_element
      def append(mix_element)
        raise(RuntimeError, 'Sequence cannot be modified after Effects applied') if has_effects?
        mix_element.add(mixer)
        @audio_mix_elements << mix_element
        @visual_mix_elements << mix_element
        mix_element.in_frame = self.duration
        mix_element.out_frame = self.duration + mix_element.duration - 1
        self.duration += mix_element.duration
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
        end
      end
      private :current_mix_element
    end
  end
end
