module RenderMix

  class RenderContext
    attr_accessor :tpf

    def initialize(render_manager, audio_context_pool, visual_context_pool)
      @render_manager = render_manager
      @audio_context_pool = audio_context_pool
      @visual_context_pool = visual_context_pool
    end

    # Create a new context sharing this contexts pools
    def clone_context
      RenderContext.new(@render_manager, @audio_context_pool, @visual_context_pool)
    end

    def begin_frame(tpf)
      @tpf = tpf
      @audio_rendered = false
      @visual_rendered = false
    end

    def acquire_audio_context(renderer)
      # Someone already rendered for this frame
      raise(InvalidMixError, "Audio rendered twice in frame") if @audio_rendered

      if @audio_renderer && renderer != @audio_renderer
        @audio_renderer.audio_context_released
        release_audio_context
      end
      @audio_renderer = renderer
      @audio_rendered = true

      @audio_context ||= @audio_context_pool.acquire_context
    end

    def acquire_visual_context(renderer)
      # Someone already rendered for this frame
      raise(InvalidMixError, "Visual rendered twice in frame") if @visual_rendered

      if @visual_renderer && renderer != @visual_renderer
        @visual_renderer.visual_context_released
        release_visual_context
      end
      @visual_renderer = renderer
      @visual_rendered = true

      @visual_context ||= @visual_context_pool.acquire_context
    end

    def end_frame
      # If we have a renderer, and nothing rendered this frame, then end it
      if @audio_renderer and not @audio_rendered
        @audio_renderer.audio_context_released
        @audio_renderer = nil
        release_audio_context
      end
      if @visual_renderer and not @visual_rendered
        @visual_renderer.visual_context_released
        @visual_renderer = nil
        release_visual_context
      end
    end

    def prepare_texture
      #XXX if @visual_context is nil, just return - caller should use no texture?
      #XXX should prepare_texture be on visual_context?

      @visual_context.rootnode.updateLogicalState(@tpf)
      @visual_context.rootnode.updateGeometricState

      #XXX the user of the texture should call this - yes, so Effect will render each input to texture before using - and toplevel app will be responsible for rendring main context
      @render_manager.renderViewPort(@visual_context.viewport, @tpf)
    end

    # Should be called prior to reusing with a new renderer
    def release_audio_context
      @audio_context_pool.release_context(@audio_context)
      @audio_context = nil
    end
    private :release_audio_context

    # Should be called prior to reusing with a new renderer
    def release_visual_context
      # Want to actually release instead of just reset because
      # the next renderer may never actually render
      @visual_context_pool.release_context(@visual_context)
      @visual_context = nil
    end
    private :release_visual_context
  end

  # Special context for the root visual - we don't use the pool to manage it
  class RootRenderContext < RenderContext
    def initialize(render_manager, audio_context_pool, visual_context_pool, visual_context)
      super(render_manager, audio_context_pool, visual_context_pool)
      @visual_context = visual_context
    end

    # Override, we don't release since we're not pooled, just reset
    def release_visual_context
      @visual_context.reset
    end
    private :release_visual_context
  end
end
