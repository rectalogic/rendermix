module RenderMix
  class AudioContext
    attr_reader :buffer

    def initialize(size)
      @buffer = FFI::Buffer.new_out(size)
    end
  end
end
