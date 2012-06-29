# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  MSAA_SAMPLES = 4
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

    # @param [String] filename
    # @param [Hash] opts (see Mix::Media#initialize)
    def new_media(filename, opts={})
      Mix::Media.new(self, filename, opts)
    end

    # @param [Mix::Base] mix root element of the mix
    # @param [String] filename the output video filename to encode into
    def mix(mix, filename=nil)
      mix.add(self)
      @app = create_mixer_application
      @app.mix(mix, filename)
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
      settings = Jme::System::AppSettings.new(false)
      settings.renderer = Jme::System::AppSettings::LWJGL_OPENGL3
      settings.setSamples(MSAA_SAMPLES)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
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

      configure_settings do |settings|
        settings.setResolution(mixer.width, mixer.height)
      end

      @mutex = Mutex.new
      @condvar = ConditionVariable.new
    end

    # _mix_ Root node of mix. Mix is destroyed as mixing proceeds.
    # _filename_ Output filename to encode mix into, if nil then mix will be displayed in a window
    def mix(mix, filename=nil)
      if filename
        @encoder = RawMedia::Encoder.new(filename, @mixer.rawmedia_session,
                                         @mixer.width, @mixer.height)
      else
        # If not encoding, limit framerate so stuff looks right
        self.settings.frameRate = @mixer.framerate.to_i
      end

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
      self.assetManager.registerLoader(JSONLoader.become_java!, "js", "json")

      @asset_locations.each do |location|
        locator_class = File.directory?(location) ?
          Jme::Asset::Plugins::FileLocator.java_class :
          Jme::Asset::Plugins::ZipLocator.java_class
        self.assetManager.registerLocator(location, locator_class)
      end

      @root_audio_context = AudioContext.new(@mixer.rawmedia_session.audio_framebuffer_size)
      @audio_context_manager = AudioContextManager.new(@mixer.rawmedia_session.audio_framebuffer_size, @root_audio_context)

      tpf = self.timer.timePerFrame
      @root_visual_context = VisualContext.new(self.renderManager, tpf, self.viewPort, self.rootNode)
      @visual_context_manager =
        VisualContextManager.new(self.renderManager, @mixer.width, @mixer.height, tpf, @root_visual_context)
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
        @encoder.destroy if @encoder
        stop
      end
    end
    private :simpleRender

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
