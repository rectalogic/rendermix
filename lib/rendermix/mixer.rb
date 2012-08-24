# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  DEPTH_FORMAT = Jme::Texture::Image::Format::Depth24

  class Mixer
    attr_reader :width
    attr_reader :height
    attr_reader :framerate
    attr_reader :rawmedia_session

    def initialize(width, height, framerate=Rational(30))
      @width = width
      @height = height
      @framerate = framerate
      @rawmedia_session = RawMedia::Session.new(framerate)
      @asset_locations = []
    end

    # @return [Jme::Asset::AssetManager] application asset manager.
    #  Only valid when called from the mixing thread.
    def asset_manager
      @app.assetManager
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
      @app = create_mixer_application
      @app.mix(mix, filename, &progress_block)
    end

    def create_mixer_application
      MixerApplication.new(self, @asset_locations)
    end
    protected :create_mixer_application
  end

  class ApplicationBase < Jme::App::SimpleApplication
    field_reader :settings
    protected :settings

    def initialize(app_states=nil)
      super(app_states)
      # Use consistent natives directory, instead of process working dir
      Jme::System::Natives.extractionDir = File.expand_path('../../../natives', __FILE__)
      self.showSettings = false
      self.pauseOnLostFocus = false
    end

    def configure_settings
      settings = Jme::System::AppSettings.new(true)
      settings.renderer = Jme::System::AppSettings::LWJGL_OPENGL2
      settings.setSamples(1)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
      settings.frameRate = -1
      settings.useInput = false
      settings.useJoysticks = false
      settings.audioRenderer = nil
      yield settings if block_given?
      self.settings = settings
    end
  end

  class MixerApplication < ApplicationBase

    def initialize(mixer, asset_locations)
      super(nil)
      @mixer = mixer
      @asset_locations = asset_locations
      self.timer = Timer.new(mixer.framerate)

      @mutex = Mutex.new
      @condvar = ConditionVariable.new
    end

    # @param [Mix::Base] mix root node of mix. Mix is modified as mixing proceeds.
    # @param [String] filename output filename to encode mix into,
    #   if nil then mix will be displayed in a window.
    # @yieldparam [Fixnum] frame number being rendered
    def mix(mix, filename=nil, &progress_block)
      configure_settings do |settings|
        if filename
          @encoder = Encoder.new(@mixer, filename)
          @encoder.configure(settings)
        else
          # If not encoding, limit framerate so we play at correct speed
          settings.frameRate = @mixer.framerate.to_i
          settings.setResolution(@mixer.width, @mixer.height)
        end
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

    def simpleInitApp
      asset_root = File.expand_path('../../../assets', __FILE__)
      self.assetManager.registerLocator(asset_root, Jme::Asset::Plugins::FileLocator.java_class)
      Asset::JSONLoader.register(self.assetManager)
      Asset::FontLoader.register(self.assetManager)

      @asset_locations.each do |location|
        locator_class = File.directory?(location) ?
          Jme::Asset::Plugins::FileLocator.java_class :
          Jme::Asset::Plugins::ZipLocator.java_class
        self.assetManager.registerLocator(location, locator_class)
      end

      root_audio_context = AudioContext.new(@mixer.rawmedia_session.audio_framebuffer_size)
      @audio_context_manager = AudioContextManager.new(@mixer.rawmedia_session.audio_framebuffer_size, root_audio_context)

      tpf = self.timer.timePerFrame

      # We don't use gui viewport.
      # Removing/disabling it causes rendering issues when we have multiple
      # SceneProcessors, so just remove the scenes.
      self.guiViewPort.clearScenes

      # Let encoder modify viewport
      @encoder.prepare(self.renderManager, self.viewPort, tpf) if @encoder

      root_visual_context = VisualContext.new(self.renderManager, tpf, self.viewPort, self.rootNode)
      @visual_context_manager =
        VisualContextManager.new(self.renderManager, @mixer.width, @mixer.height, tpf, root_visual_context)
    end
    private :simpleInitApp

    def simpleUpdate(tpf)
      @audio_context_manager.render(@mix)
      @visual_context_manager.render(@mix)

      # Configure antialiasing for this frame
      antialias = @visual_context_manager.reset_antialias
      visual_context = @visual_context_manager.current_context
      if visual_context
        visual_context.set_antialias_filter(@mixer.asset_manager,
                                            antialias ? antialias_filter : nil)
      end
    end
    private :simpleUpdate

    def simpleRender(render_manager)
      if @encoder
        @encoder.encode(@audio_context_manager.current_context,
                        @visual_context_manager.current_context)
      end
      @progress_block.call(@current_frame) if @progress_block

      # Update frame and quit if mix completed
      @current_frame += 1
      if @current_frame > @mix.out_frame
        @encoder.finish if @encoder
        stop
      end
    end
    private :simpleRender

    def antialias_filter
      unless @antialias_filter
        @antialias_filter = Jme::Post::Filters::FXAAFilter.new
        # Higher quality, but blurrier
        @antialias_filter.subPixelShift = 0
        @antialias_filter.reduceMul = 0
      end
      @antialias_filter
    end
    private :antialias_filter

    # Override and return nil - we don't need this and slows startup
    def loadGuiFont
    end
    private :loadGuiFont

    def destroy
      super
      @mutex.synchronize do
        @condvar.signal
      end
    end
    private :destroy

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
