# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class AudioContext
    attr_reader :buffer

    # @param [Mixer] mixer
    def initialize(mixer)
      @buffer = FFI::MemoryPointer.new(mixer.rawmedia_session.audio_framebuffer_size)
    end
  end
end
