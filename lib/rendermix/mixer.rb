module RenderMix
  MSAA_SAMPLES = 4
  DEPTH_FORMAT = JmeTexture::Image::Format::Depth24

  class Mixer < JmeApp::SimpleApplication
    def initialize(width, height, framerate)
      super(nil)
      self.timer = Timer.new(framerate)
      self.showSettings = false
      self.pauseOnLostFocus = false

      settings = JmeSystem::AppSettings.new(false)
      settings.renderer = JmeSystem::AppSettings::LWJGL_OPENGL3
      settings.setResolution(width, height)
      settings.setSamples(MSAA_SAMPLES)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
      settings.useInput = false
      settings.audioRenderer = nil
      self.settings = settings

      @rawmedia_session = RawMedia::Session.new(width, height, framerate)

      @width = width
      @height = height
    end

    # If encoder is not set, then render to onscreen window.
    # _mix_ Root node of mix. Mix is destroyed as mixing proceeds.
    # _filename_ Output filename to encode mix into, if nil then mix will be displayed in a window
    def mix(mix, filename=nil)
      @encoder = RawMedia::Encoder.new(filename, @rawmedia_session) if filename
      @mix = mix
      @current_frame = 0
      @mix.in_frame = 0
      @mix.out_frame = @mix.duration - 1
      self.start(@encoder ?
                 JmeSystem::JmeContext::Type::OffscreenSurface :
                 JmeSystem::JmeContext::Type::Display)
    end

    def new_blank(duration)
      Mix::Blank.new(duration)
    end

    def new_sequence
      Mix::Sequence.new
    end

    def new_parallel
      Mix::Parallel.new
    end

    def new_image(filename, duration)
      Mix::Image.new(filename, duration)
    end

    def new_media(filename, start_frame=0, duration=nil)
      Mix::Media.new(rawmedia_session, filename, start_frame, duration)
    end

    def simpleInitApp
      audio_context = AudioContext.new(@rawmedia_session.audio_framebuffer_size)
      @audio_context_manager = AudioContextManager.new(@rawmedia_session.audio_framebuffer_size, audio_context)

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

    def simpleRender(render_manager)
      if @encoder
        #XXX encode audio/video
        #XXX also need to know if nothing rendered this frame and encode silence or black
      end

      # Update frame and quit if mix completed
      @current_frame += 1
      stop if @current_frame > @mix.out_frame
    end
    private :simpleRender

    def handleError(msg, ex)
      super
      raise ex
    end
    private :handleError
  end
end
