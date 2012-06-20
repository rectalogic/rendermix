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

    def initialize(width, height, framerate)
      @width = width
      @height = height
      @framerate = framerate
      @rawmedia_session = RawMedia::Session.new(framerate)
      @app = MixerApplication.new(self)
    end

    def asset_manager
      @app.assetManager
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

    def mix(mix, filename=nil)
      mix.add(self)
      @app.mix(mix, filename)
    end
  end

  class ApplicationBase < Jme::App::SimpleApplication
    def initialize(app_states=nil)
      super(app_states)
      # Use consistent natives directory, instead of process working dir
      Jme::System::Natives.extractionDir = File.expand_path('../../../natives', __FILE__)
      self.showSettings = false
      self.pauseOnLostFocus = false
    end

    def default_settings
      settings = Jme::System::AppSettings.new(false)
      settings.renderer = Jme::System::AppSettings::LWJGL_OPENGL3
      settings.setSamples(MSAA_SAMPLES)
      settings.setDepthBits(DEPTH_FORMAT.bitsPerPixel)
      settings.useInput = false
      settings.useJoysticks = false
      settings.audioRenderer = nil
      settings
    end
  end

  class MixerApplication < ApplicationBase
    def initialize(mixer)
      super(nil)
      @mixer = mixer
      self.timer = Timer.new(mixer.framerate)

      settings = default_settings
      settings.setResolution(mixer.width, mixer.height)
      self.settings = settings

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
