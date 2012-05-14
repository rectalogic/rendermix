# Timer that is independent of real time
module RenderMix
  class Timer < JmeSystem::Timer
    def initialize(framerate)
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
      @ticks++
    end

    def reset
      @ticks = 0
    end
  end
end
