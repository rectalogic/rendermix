# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix

  class ContextManager

    def initialize(context_pool, name, initial_context=nil)
      @context_pool = context_pool
      @name = name
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
      @antialias = nil
    end

    # @param [#visual_render, #visual_context_released,
    #  #audio_render, #audio_context_released] renderer
    #  should implement either the set of visual or audio methods,
    #  depending on the ContextManager subclass.
    # Subclasses must implement #on_render(renderer) hook
    def render(renderer)
      @rendered = false

      on_render(renderer)

      # If we have a renderer, and nothing rendered this frame, then end it
      release_context unless @rendered
    end

    # @return [AudioContext, VisualContext, nil] returns the current context if
    #  the context was acquired during the last #render
    #  Returns nil if nothing was rendered.
    def current_context
      return @context if @rendered
    end

    def acquire_context(renderer)
      # Someone already rendered for this frame
      raise(InvalidMixError, "#@name frame already rendered for this context") if @rendered

      release_context if renderer != @current_renderer
      @current_renderer = renderer
      @rendered = true

      @context ||= @context_pool.acquire_context
    end

    # Subclasses should implement on_release_context
    def release_context
      return unless @current_renderer
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

    # Request global antialiasing via this ContextManager
    def request_antialias
      @antialias = true
    end

    # Reset antialias request
    # @return [Boolean] true if antialias was requested
    def reset_antialias
      antialias = @antialias
      @antialias = nil
      antialias
    end
  end

  class AudioContextManager < ContextManager
    def initialize(audio_framebuffer_size, initial_context=nil)
      super(AudioContextPool.new(audio_framebuffer_size), 'Audio', initial_context)
    end

    def on_render(renderer)
      renderer.audio_render(self)
    end
    protected :on_render

    def on_release_context(renderer, context)
      renderer.audio_context_released(context)
    end
    protected :on_release_context
  end

  class VisualContextManager < ContextManager
    def initialize(render_manager, width, height, tpf, initial_context=nil)
      super(VisualContextPool.new(render_manager, width, height, tpf), 'Visual', initial_context)
    end

    def on_render(renderer)
      renderer.visual_render(self)
    end
    protected :on_render

    def on_release_context(renderer, context)
      renderer.visual_context_released(context)
    end
    protected :on_release_context
  end
end
