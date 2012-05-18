module RenderMix
  class AudioContext
    attr_reader :buffer

    def initialize(size)
      @buffer = JavaNIO::ByteBuffer.allocate(size)
    end
  end
end
