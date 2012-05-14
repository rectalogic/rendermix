module RenderMix
  class Mixer < JmeApp::SimpleApplication
    attr_reader :rawmedia_session

    def initialize(width, height, framerate)
      super([RenderAppState.new(self)].to_java(JmeAppState::AppState))
      self.timer = Timer.new(framerate)
      self.showSettings = false

      settings = JmeSystem::AppSettings.new(false)
      settings.renderer = JmeSystem::AppSettings::LWJGL_OPENGL3
      settings.setResolution(width, height)
      settings.setSamples(4) # MSAA XXX may not want this here, want on individual FBOs we render into
      settings.useInput = false
      settings.audioRenderer = nil
      settings.frameRate = framerate.to_i
      self.settings = settings

      #XXX need to get session to decoders too though - caller can do that - we ca expose session and caller can create their media decoders with it
      @rawmedia_session = RawMedia::Session.new(width, height, framerate)
      @frame_number = 0
      @width = width
      @height = height
    end

    # If encoder is not set, then render to window onscreen
    def mix(renderable, encoder=nil)
      #XXX do something with encoder if set
      @renderable = renderable
      self.start(encoder
                 ? JmeSystem::JmeContext::Type::OffscreenSurface
                 : JmeSystem::JmeContext::Type::Display)
    end

    def simpleInitApp
      viewport_pool = ViewportPool.new(@width, @height)
      @render_context = RootRenderContext.new(viewport_pool, self.viewPort)
    end
    private :simpleInitApp

    def pre_render(render_manager)
      #XXX should context provide audio buffer and video camera/node?
      #XXX deeper effects can create their own context e.g. to render each track into it's own audio buffer or scene node
      #XXX we need to know if either audio or video was rendered - and Parallel needs to know to validate - maybe render_frame returns two booleans?
      @renderable.render_frame(@frame_number, @render_context)
      @frame_number++

      #XXX our multi-pass hierarchy won't work - we can't set textures on an effect until the source renderable has rendered
      #XXX hmm, might work - because we will use the FrameBuffers Texture, and it will be drawn when we render that Viewport - so we just need Viewports/FBOs rendered in the correct order
        #XXX ViewPorts rendered in order created, FBO is the expensive piece so maybe can cache those and create ViewPorts as needed?
        #XXX or call renderViewPort(vp,tpf) explicitly in the order we need

        #XXX so maybe our RenderContext should manually create a ViewPort and explicitly render it so the parents fbo/texture is ready
        #XXX so all this should be in simpleRender, and super() last to render main - hmm simpleRender is called right after real render - stateManager.render is called right before so could use an AppState
    end
    private :pre_render

    def post_render
      #XXX encode if encoder is set
    end
    private :post_render
  end

  class RenderAppState < JmeAppState::AbstractAppState
    def initialize(app)
      super()
      @app = app
    end

    def render(render_manager)
      @app.pre_render(render_manager)
    end

    def postRender
      @app.post_render
    end
  end
end
