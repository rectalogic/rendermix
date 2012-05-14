module RenderMix

  class RenderContext
    attr_reader :viewport_pool

    def initialize(viewport_pool)
      @viewport_pool = viewport_pool
    end

    def viewport
      @viewport ||= @viewport_pool.allocate_viewport
    end

    # Return the Texture2D this contexts viewport is rendering into
    #XXX stick ImageContext objects in pool, can wrap Viewport and expose texture, Node, Camera etc. Then can have AudioContext pool too of buffers
    def texture
      @viewport_pool.texture(viewport)
    end

    #XXX need a render method to actually render viewport into FBO
    #XXX also to render audio, and set flag so we know we rendered
    #XXX can we use this flag to blow up? i.e. if flag set and someone renders, then that's illegal (reset between frames)

    #XXX how does context user know when to setup their scene? not safe for them to cache the viewport, they get no notice when they are done - they know their duration though so could cleanup when done? 
    #XXX need Renderable render_begin, render, render_end
    #XXX can we keep track of renderable in context? and if a diff one tries to render, then cleanup and notify the old one, then if a 2nd tries in the same frame blow up

    #XXX audio may complicate this - may have track A rendering video and no audio, and track B in parallel rendering audio and no video

    # Should be called prior to reusing with a new renderable
    def init
      @viewport_pool.release_viewport(@viewport)
      @viewport = nil
    end
  end

  # Special context for the root viewport - we don't use the pool to manage it
  class RootRenderContext < RenderContext
    def initialize(viewport_pool, viewport)
      super(viewport_pool)
      @viewport = viewport
    end

    def texture
      nil
    end

    def init
      @viewport.clearScenes
    end
  end
end
