# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

# Timer that is independent of real time
module RenderMix
  class Timer < JmeSystem::Timer
    def initialize(framerate)
      super()
      @framerate = framerate.to_r
      @ticks = 0
    end

    def getTime
      @ticks
    end

    def getResolution
      @framerate.to_i
    end

    def getFrameRate
      @framerate.to_f
    end

    def getTimePerFrame
      @framerate.denominator.to_f / @framerate.numerator
    end

    def update
      @ticks += 1
    end

    def reset
      @ticks = 0
    end
  end
end
