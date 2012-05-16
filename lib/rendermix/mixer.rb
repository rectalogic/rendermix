module RenderMix
  MSAA_SAMPLES = 4
  DEPTH_FORMAT = JmeTexture::Image::Format::Depth24

  class Mixer < JmeApp::SimpleApplication
    attr_reader :rawmedia_session

    def initialize(width, height, framerate)
      super(nil)
      self.timer = Timer.new(framerate)
      self.showSettings = false

      settings = JmeSystem::AppSettings.new(false)
      settings.renderer = JmeSystem::AppSettings::LWJGL_OPENGL3
      settings.setResolution(width, height)
      settings.setSamples(MSAA_SAMPLES)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
      settings.useInput = false
      settings.audioRenderer = nil
      self.settings = settings

      #XXX need to get session to decoders too though - caller can do that - we ca expose session and caller can create their media decoders with it
      @rawmedia_session = RawMedia::Session.new(width, height, framerate)

      @width = width
      @height = height
    end

    # If encoder is not set, then render to onscreen window
    def mix(mix, encoder=nil)
      #XXX do something with encoder if set
      @mix = mix
      mix.in_frame = 0
      mix.out_frame = mix.duration - 1
      self.start(encoder
                 ? JmeSystem::JmeContext::Type::OffscreenSurface
                 : JmeSystem::JmeContext::Type::Display)
    end

    def simpleInitApp
      @audio_context_manager = AudioContextManager.new(@rawmedia_session.audio_framebuffer_size)

      tpf = self.timer.timePerFrame
      visual_context = VisualContext.new(self.renderManager, tpf, self.viewPort, self.rootNode)
      @visual_context_manager =
        VisualContextManager.new(self.renderManager, @width, @height, tpf, visual_context)
    end
    private :simpleInitApp

    def simpleUpdate(tpf)
      #XXX deeper effects can create their own context e.g. to render each track into it's own audio buffer or scene node
      @audio_context_manager.render(@mix)
      @visual_context_manager.render(@mix)
    end
    private :simpleUpdate

    #XXX simplRender to encode
    def simpleRender(render_manager)
      #XXX encode if encoder set
    end
    private :simpleRender
  end
end
