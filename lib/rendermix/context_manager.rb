module RenderMix

  class ContextManager

    def initialize(context_pool)
      @context_pool = context_pool
      @rendered = false
    end

    # Use clone to create a new context sharing this contexts pools
    def initialize_copy(source)
      super
      @current_renderer = nil
      @rendered = false
      @context = nil
    end

    # Subclasses must implement on_render(renderer) hook
    def render(renderer)
      @rendered = false

      on_render(renderer)

      # If we have a renderer, and nothing rendered this frame, then end it
      release_context if @current_renderer and not @rendered
    end

    def acquire_context(renderer)
      # Someone already rendered for this frame
      raise(InvalidMixError, "Frame double render") if @rendered

      release_context if @current_renderer && renderer != @current_renderer
      @current_renderer = renderer
      @rendered = true

      @context ||= @context_pool.acquire_context
    end

    # Subclass should override this and invoke super after informing current_renderer
    def release_context(pooled=true)
      @current_renderer = nil
      # If context not pooled, keep it
      if pooled
        @context_pool.release_context(@context)
        @context = nil
      end
    end
    private :release_context

    def context
      @context
    end
    private :context

    def current_renderer
      @current_renderer
    end
    private :current_renderer
  end
end
