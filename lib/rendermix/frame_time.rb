# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module FrameTime
    # @param [Fixnum] frame frame number
    # @param [Fixnum] duration duration to resolve against
    # @return [Float] normalized time (0..1)
    def frame_to_time(frame, duration)
      frame / (duration - 1).to_f
    end
  end
end
