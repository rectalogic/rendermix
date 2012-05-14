module RenderMix

  class RenderContext
    def initialize(render_manager, audio_context_pool, visual_context_pool)
      @render_manager = render_manager
      @audio_context_pool = audio_context_pool
      @visual_context_pool = visual_context_pool
    end

    # Create a new context sharing this contexts pools
    def clone_context
      RenderContext.new(@render_manager, @audio_context_pool, @visual_context_pool)
    end

    def audio_context
      @audio_context ||= @audio_context_pool.allocate_context
    end

    def visual_context
      @visual_context ||= @visual_context_pool.allocate_context
    end


    #XXX need a render method to actually render viewport into FBO
    #XXX also to render audio, and set flag so we know we rendered
    #XXX can we use this flag to blow up? i.e. if flag set and someone renders, then that's illegal (reset between frames)

    #XXX how does context user know when to setup their scene? not safe for them to cache the viewport, they get no notice when they are done - they know their duration though so could cleanup when done? 
    #XXX need Renderable render_begin, render, render_end
    #XXX can we keep track of renderable in context? and if a diff one tries to render, then cleanup and notify the old one, then if a 2nd tries in the same frame blow up

    #XXX but a renderable may end and we have blank that doesn't render - so we never trigger the old renderable to clean up or release it's context
    #XXX could add frame_complete to RenderContext - so after all renderables render, we can check 
    #XXX so begin_frame/end_frame on RenderContext

    #XXX audio may complicate this - may have track A rendering video and no audio, and track B in parallel rendering audio and no video

    def render_audio(renderable)
      if @audio_renderable
        @audio_renderable.
    end

    def render_video(renderable)
      #XXX also need to render viewport using render_manager
    end

    # Should be called prior to reusing with a new renderable
    def release_audio
      @audio_context_pool.release_context(@audio_context)
      @audio_context = nil
    end

    # Should be called prior to reusing with a new renderable
    def release_visual
      # Want to actually release instead of just reset because
      # the next renderable may never actually render
      @visual_context_pool.release_context(@visual_context)
      @visual_context = nil
    end
  end

  # Special context for the root visual - we don't use the pool to manage it
  class RootRenderContext < RenderContext
    def initialize(render_manager, audio_context_pool, visual_context_pool, visual_context)
      super(render_manager, audio_context_pool, visual_context_pool)
      @visual_context = visual_context
    end

    # Override, we don't release since we're not pooled, just reset
    def release_visual
      @visual_context.reset
    end
  end
end
