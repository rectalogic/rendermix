module RenderMix
  MSAA_SAMPLES = 4
  DEPTH_FORMAT = JmeTexture::Image::Format::Depth24

  class Mixer
    attr_reader :width
    attr_reader :height
    attr_reader :framerate
    attr_reader :rawmedia_session

    def initialize(width, height, framerate)
      @width = width
      @height = height
      @framerate = framerate
      @rawmedia_session = RawMedia::Session.new(width, height, framerate)
      @app = MixerApplication.new(self)
    end

    def new_blank(duration)
      Mix::Blank.new(self, duration)
    end

    def new_sequence
      Mix::Sequence.new(self)
    end

    def new_parallel
      Mix::Parallel.new(self)
    end

    def new_image(filename, duration)
      Mix::Image.new(self, filename, duration)
    end

    def new_media(filename, start_frame=0, duration=nil)
      Mix::Media.new(self, filename, start_frame, duration)
    end

    def mix(mix, filename=nil)
      raise(InvalidMixError, 'Mix was not created by this Mixer') if mix.mixer != self
      @app.mix(mix, filename)
    end
  end

  class MixerApplication < JmeApp::SimpleApplication
    def initialize(mixer)
      super(nil)
      @mixer = mixer
      # Use consistent natives directory, instead of process working dir
      JmeSystem::Natives.extractionDir = File.expand_path('../../../natives', __FILE__)
      self.timer = Timer.new(mixer.framerate)
      self.showSettings = false
      self.pauseOnLostFocus = false

      settings = JmeSystem::AppSettings.new(false)
      settings.renderer = JmeSystem::AppSettings::LWJGL_OPENGL3
      settings.setResolution(mixer.width, mixer.height)
      settings.setSamples(MSAA_SAMPLES)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
      settings.useInput = false
      settings.useJoysticks = false
      settings.audioRenderer = nil
      self.settings = settings

      @mutex = Mutex.new
      @condvar = ConditionVariable.new
    end

    # _mix_ Root node of mix. Mix is destroyed as mixing proceeds.
    # _filename_ Output filename to encode mix into, if nil then mix will be displayed in a window
    def mix(mix, filename=nil)
      @encoder = RawMedia::Encoder.new(filename, @mixer.rawmedia_session) if filename
      @mix = mix
      @current_frame = 0
      @mix.in_frame = 0
      @mix.out_frame = @mix.duration - 1
      @error = nil
      @mutex.synchronize do
        self.start(@encoder ?
                   JmeSystem::JmeContext::Type::OffscreenSurface :
                   JmeSystem::JmeContext::Type::Display)
        @condvar.wait(@mutex)
      end
      raise @error if @error
    end

    def simpleInitApp
      # Register filesystem root so we can load textures from anywhere
      self.assetManager.registerLocator('/', JmeAssetPlugins::FileLocator.java_class)

      audio_context = AudioContext.new(@mixer.rawmedia_session.audio_framebuffer_size)
      @audio_context_manager = AudioContextManager.new(@mixer.rawmedia_session.audio_framebuffer_size, audio_context)

      tpf = self.timer.timePerFrame
      visual_context = VisualContext.new(self.renderManager, tpf, self.viewPort, self.rootNode)
      @visual_context_manager =
        VisualContextManager.new(self.renderManager, @mixer.width, @mixer.height, tpf, visual_context)
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
      if @current_frame > @mix.out_frame
        @mutex.synchronize do
          stop
          @encoder.destroy if @encoder
          @condvar.signal
        end
      end
    end
    private :simpleRender

    def handleError(msg, ex)
      @mutex.synchronize do
        super
        @error = ex
        @condvar.signal
      end
    end
    private :handleError
  end
end
