# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix

  class ContextManager
    def initialize(name)
      @name = name
      @rendered = false
    end

    # @param [#visual_render, #audio_render] renderer
    #  should implement either the visual or audio methods,
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

      @context ||= create_context
    end

    def release_context
      @current_renderer = nil
      @context = nil
    end
  end

  class AudioContextManager < ContextManager
    def initialize
      super('Audio')
    end

    def create_context
      AudioContext.new
    end

    def on_render(renderer)
      renderer.audio_render(self)
    end
    protected :on_render
  end

  class VisualContextManager < ContextManager
    def initialize
      super('Visual')
    end

    def create_context
      VisualContext.new
    end

    def on_render(renderer)
      renderer.visual_render(self)
    end
    protected :on_render
  end
end
