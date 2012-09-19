# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix

  class ContextManager
    # Subclass specific context.
    # @return [AudioContext, VisualContext, nil] the context set during
    #   the last render, or nil if none
    attr_reader :context

    def initialize(name)
      @name = name
    end

    # Set subclass specific context.
    def context=(context)
      raise(InvalidMixError, "#@name context already set for this frame") if context and @context
      @context = context
    end

    # @param [#visual_render, #audio_render] renderer
    #  should implement either the visual or audio methods,
    #  depending on the ContextManager subclass.
    # Subclasses must implement #on_render(renderer) hook
    def render(renderer)
      @context = nil
      on_render(renderer)
    end
  end

  class AudioContextManager < ContextManager
    def initialize
      super('Audio')
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

    def on_render(renderer)
      renderer.visual_render(self)
    end
    protected :on_render
  end
end
