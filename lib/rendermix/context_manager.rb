module RenderMix

  class ContextManager

    def initialize(context_pool, initial_context=nil)
      @context_pool = context_pool
      @initial_context = initial_context
      @context = initial_context
      @rendered = false
    end

    # Use clone to create a new context sharing this contexts pools
    def initialize_copy(source)
      super
      @current_renderer = nil
      @rendered = false
      @context = nil
      @initial_context = nil
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

    # Subclasses should implement on_release_context
    def release_context
      on_release_context(@current_renderer)
      @current_renderer = nil
      # If context not pooled, keep it
      if @context != @initial_context
        @context_pool.release_context(@context)
        @context = nil
      elsif @initial_context
        @context_pool.reset_context(@initial_context)
      end
    end
    private :release_context
  end
end
