module RenderMix
#XXX this is backwards - the context creator doesn't know if 3d is needed, e.g. an Effect needs it for it's output but the root context won't know ahead of time if it should be 3d

  class RenderContext
    attr_reader :viewport_pool

    def initialize(viewport_pool, need_3d=false)
      @viewport_pool = viewport_pool
      @need_3d = need_3d
    end

    def viewport
      @viewport ||= @viewport_pool.allocate_viewport(@need_3d)
    end

    def texture
      @viewport_pool.texture(viewport)
    end

    #XXX need a render method to actually render viewport into FBO
    #XXX also to render audio, and set flag so we know we rendered
    #XXX can we use this flag to blow up? i.e. if flag set and someone renders, then that's illegal (reset between frames)

    def reset
      @viewport_pool.release_viewport(@viewport, @need_3d)
      @viewport = nil
    end
  end

  # Special context for the root viewport - we don't use a pool to manage it
  class RootRenderContext < RenderContext
    def initialize(viewport_pool, viewport)
      super(viewport_pool)
      @viewport = viewport
    end

    def texture
      nil
    end

    def reset
      @viewport.clearScenes
    end
  end
end
