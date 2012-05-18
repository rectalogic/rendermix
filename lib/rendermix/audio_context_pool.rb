module RenderMix
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
