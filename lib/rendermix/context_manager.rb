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

    # @return [Boolean] returns true if renderer acquired the context when
    #  rendering. (i.e. something was actually rendered)
    def rendered?
      @rendered
    end

    def acquire_context(renderer)
      # Someone already rendered for this frame
      raise(InvalidMixError, "Frame already rendered for this context") if @rendered

      release_context if @current_renderer && renderer != @current_renderer
      @current_renderer = renderer
      @rendered = true

      @context ||= @context_pool.acquire_context
    end

    # Subclasses should implement on_release_context
    def release_context
      on_release_context(@current_renderer, @context)
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

  class AudioContextManager < ContextManager
    def initialize(audio_framebuffer_size, initial_context=nil)
      super(AudioContextPool.new(audio_framebuffer_size), initial_context)
    end

    def on_render(renderer)
      renderer.render_audio(self)
    end
    private :on_render

    def on_release_context(renderer, context)
      renderer.audio_context_released(context)
    end
    private :on_release_context
  end

  class VisualContextManager < ContextManager
    def initialize(render_manager, width, height, tpf, initial_context=nil)
      super(VisualContextPool.new(render_manager, width, height, tpf), initial_context)
      @render_manager = render_manager
    end

    def on_render(renderer)
      renderer.render_visual(self)
    end
    private :on_render

    def on_release_context(renderer, context)
      renderer.visual_context_released(context)
    end
    private :on_release_context
  end
end
