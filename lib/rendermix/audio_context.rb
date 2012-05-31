module RenderMix
  class AudioContext
    attr_reader :buffer

    def initialize(size)
      @buffer = FFI::MemoryPointer.new(size)
    end
  end
end
