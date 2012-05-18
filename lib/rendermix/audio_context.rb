module RenderMix
  class AudioContext
    attr_reader :buffer

    def initialize(size)
      @buffer = JavaNIO::ByteBuffer.allocate(size)
    end
  end

  class AudioContextPool
    def initialize(size)
      @contexts = []
      @size = size
    end

    def acquire_context
      return @contexts.pop unless @contexts.empty?
      AudioContext.new(@size)
    end

    def release_context(context)
      @contexts << context if context
      reset_context(context)
    end

    def reset_context(context)
      #XXX should we zero buffer?
    end
  end
end
