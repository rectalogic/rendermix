# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  DEPTH_FORMAT = Jme::Texture::Image::Format::Depth24

  # Use consistent natives directory, instead of process working dir
  Jme::System::Natives.extractionDir = File.expand_path('../../../natives', __FILE__)

  class Mixer
    attr_reader :width
    attr_reader :height
    attr_reader :framerate
    attr_reader :rawmedia_session
    # @return [RenderSystem]
    attr_reader :render_system

    #XXX setup jme logging, also need to redirect rawmedia logging - should we do this here or in command.rb? (also logging for specs)
    def initialize(width, height, framerate=Rational(30))
      @width = width
      @height = height
      @framerate = framerate
      @rawmedia_session = RawMedia::Session.new(framerate)
      @asset_locations = []
      @render_system = create_render_system(@asset_locations)
    end

    # @param [String] location filesystem path to an asset root.
    #  Root directory or zip file.
    def register_asset_location(location)
      raise(InvalidMixError, "Asset location does not exist") unless File.exist?(location)
      @asset_locations.push(location) unless @asset_locations.include?(location)
    end

    # @param [Hash] opts (see {Mix::Blank#initialize})
    def new_blank(opts)
      Mix::Blank.new(self, opts)
    end

    # @param [Array<Mix::Base>] mix_elements
    def new_sequence(*mix_elements)
      Mix::Sequence.new(self, mix_elements.flatten)
    end

    # @param [Array<Mix::Base>] mix_elements
    def new_parallel(*mix_elements)
      Mix::Parallel.new(self, mix_elements.flatten)
    end

    # @param [String] filename
    # @param [Hash] opts (see {Mix::Image#initialize})
    def new_image(filename, opts={})
      Mix::Image.new(self, filename, opts)
    end

    # @param [String] filename
    # @param [Hash] opts (see {Mix::Media#initialize})
    def new_media(filename, opts={})
      Mix::Media.new(self, filename, opts)
    end

    # @param [Mix::Base] mix root element of the mix
    # @param [String] filename the output video filename to encode into
    # @yieldparam [Fixnum] frame number being rendered
    def mix(mix, filename=nil, &progress_block)
      mix.validate(self)
      @render_system.mix(mix, filename, &progress_block)
    end

    # @return [MixRenderSystem]
    def create_render_system(asset_locations)
      MixRenderSystem.new(self, asset_locations)
    end
    protected :create_render_system
  end

  class RenderSystem
    include Jme::System::SystemListener

    # @return [Jme::Asset::AssetManager] asset manager
    attr_reader :asset_manager
    # @return [Jme::System::AppSettings]
    attr_reader :settings
    # @return [Jme::Renderer::RenderManager]
    attr_reader :render_manager
    # @return [Jme::System::Timer]
    attr_reader :timer

    # Hack so we can implement SystemListener.initialize
    def self.new(*args)
      instance = allocate
      instance.send(:ruby_initialize, *args)
      instance
    end

    # @param [Jme::System::Timer] timer
    def ruby_initialize(timer)
      @settings = create_settings
      @timer = timer
    end
    protected :ruby_initialize

    def start(context_type)
      @context = Jme::System::JmeSystem.newContext(@settings, context_type)
      @context.setSystemListener(self)
      @context.create(false)
    end

    def stop(wait=false)
      @context.destroy(wait)
    end

    def create_settings
      settings = Jme::System::AppSettings.new(true)
      settings.renderer = Jme::System::AppSettings::LWJGL_OPENGL2
      settings.setSamples(1)
      settings.setDepthBits(0)
      settings.frameRate = -1
      settings.useInput = false
      settings.useJoysticks = false
      settings.audioRenderer = nil
      settings
    end
    private :create_settings

    # Implements SystemListener
    def initialize
      config = java.lang.Thread::currentThread.getContextClassLoader.getResource('com/jme3/asset/Desktop.cfg')
      @asset_manager = Jme::System::JmeSystem::newAssetManager(config)
      @render_manager = Jme::Renderer::RenderManager.new(@context.getRenderer)
      @render_manager.setTimer(@timer)
      #XXX hack to set internal 'shader' ivar - patch this in JME RenderManager
      @render_manager.render(0, false)
    end

    # Implements SystemListener
    def update
      @timer.update
    end

    # Implements SystemListener
    def gainFocus; end
    # Implements SystemListener
    def loseFocus; end
    # Implements SystemListener
    def handleError(m, e); end
    # Implements SystemListener
    def reshape(w, h); end
    # Implements SystemListener
    def requestClose(esc)
      stop
    end
  end

  class MixRenderSystem < RenderSystem
    def ruby_initialize(mixer, asset_locations)
      super(Timer.new(mixer.framerate))
      @mixer = mixer
      @asset_locations = asset_locations
      @logger = JavaLog::Logger::getLogger('MixRenderSystem')

      @mutex = Mutex.new
      @condvar = ConditionVariable.new
    end
    protected :ruby_initialize

    # @param [Mix::Base] mix root node of mix. Mix is modified as mixing proceeds.
    # @param [String] filename output filename to encode mix into,
    #   if nil then mix will be displayed in a window.
    # @yieldparam [Fixnum] frame number being rendered
    def mix(mix, filename=nil, &progress_block)
      if filename
        @encoder = Encoder.new(@mixer, filename)
        @encoder.configure(self.settings)
      else
        # If not encoding, limit framerate so we play at correct speed
        self.settings.frameRate = @mixer.framerate.to_i
        self.settings.setResolution(@mixer.width, @mixer.height)
      end

      @progress_block = progress_block
      @mix = mix
      @current_frame = 0
      @mix.in_frame = 0
      @mix.out_frame = @mix.duration - 1
      @error = nil
      @mutex.synchronize do
        self.start(@encoder ?
                   Jme::System::JmeContext::Type::OffscreenSurface :
                   Jme::System::JmeContext::Type::Display)
        @condvar.wait(@mutex)
      end
      raise @error if @error
    end

    # Implements SystemListener
    def initialize
      super

      asset_root = File.expand_path('../../../assets', __FILE__)
      self.asset_manager.registerLocator(asset_root, Jme::Asset::Plugins::FileLocator.java_class)
      Asset::JSONLoader.register(self.asset_manager)
      Asset::FontLoader.register(self.asset_manager)

      @asset_locations.each do |location|
        locator_class = File.directory?(location) ?
          Jme::Asset::Plugins::FileLocator.java_class :
          Jme::Asset::Plugins::ZipLocator.java_class
        self.asset_manager.registerLocator(location, locator_class)
      end

      @audio_context_manager = AudioContextManager.new
      @visual_context_manager = VisualContextManager.new

      # Let encoder prepare for encoding
      @encoder.prepare if @encoder
    end
    private :initialize

    # Implements SystemListener
    def update
      super

      @audio_context_manager.render(@mix)
      @visual_context_manager.render(@mix)

      if @encoder
        @encoder.encode(@audio_context_manager.context,
                        @visual_context_manager.context)
      else
        # Render toplevel scene
        vc = @visual_context_manager.context
        vc.render_scene if vc
        # Blit rendered FBO to window
        vc.copy_framebuffer
        # On MacOS, buffers are not swapped unless the default FB is active.
        # http://renderingpipeline.com/2012/05/nsopenglcontext-flushbuffer-might-not-do-what-you-think/
        render_manager.renderer.setFrameBuffer(nil)
      end

      @progress_block.call(@current_frame) if @progress_block

      # Update frame and quit if mix completed
      @current_frame += 1
      if @current_frame > @mix.out_frame
        @encoder.finish if @encoder
        stop
      end
    end
    private :update

    # Implements SystemListener
    def destroy
      @mutex.synchronize do
        @condvar.signal
      end
    end
    private :destroy

    # Implements SystemListener
    def handleError(msg, ex)
      @mutex.synchronize do
        @logger.log(JavaLog::Level::SEVERE, msg, ex)
        stop
        @error = ex
        @condvar.signal
      end
    end
    private :handleError
  end
end
