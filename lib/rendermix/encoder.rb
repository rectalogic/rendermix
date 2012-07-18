# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class Encoder
    def initialize(mixer, filename)
      @encoder = RawMedia::Encoder.new(filename, mixer.rawmedia_session,
                                       mixer.width, mixer.height)
      @mixer = mixer
      size = (mixer.width / 2) * mixer.height * 4
      @visual_buffer_pointer = FFI::MemoryPointer.new(size)
      @visual_byte_buffer = RawMedia::Util.wrap_pointer(@visual_buffer_pointer)
    end

    # @param [Jme::System::AppSettings] settings
    def configure(settings)
      # Configure 1x1 offscreen pbuffer, no depth buffer.
      # We will install an override FBO and not render to pbuffer.
      settings.setResolution(1, 1)
      settings.depthBits = 0
    end

    # @param [Jme::Renderer::RenderManager] render_manager
    # @param [Jme::Renderer::ViewPort] viewport
    # @param [Float] tpf
    def prepare(render_manager, viewport, tpf)
      @render_manager = render_manager
      @renderer = render_manager.renderer
      @output_texture_fbo = create_output_texture_fbo
      @uyvy_visual_context =
        create_uyvy_visual_context(render_manager, tpf, @output_texture_fbo.colorBuffer.texture)

      viewport.camera.resize(@mixer.width, @mixer.height, true)

      # Override main output FBO
      @renderer.mainFrameBufferOverride = @output_texture_fbo
      viewport.outputFrameBuffer = @output_texture_fbo
    end

    def encode(audio_context, visual_context)
      audio_buffer = audio_context ? audio_context.buffer : audio_silence_buffer
      @encoder.encode_audio(audio_buffer)

      @visual_byte_buffer.clear
      if visual_context
        # Render into our UYVY texture fbo
        @uyvy_visual_context.prepare_texture
        # Read back the UYVY data
        @uyvy_visual_context.read_framebuffer(@visual_byte_buffer)
        @encoder.encode_video(@visual_buffer_pointer, @visual_buffer_pointer.size)
      else
        @encoder.encode_video(visual_black_buffer, visual_black_buffer.size)
      end
    end

    def finish
      @encoder.destroy
    end

    # Create an FBO with a texture we can render the main scene into.
    # We need it in a texture to UYVY process it.
    def create_output_texture_fbo
      fbo = Jme::Texture::FrameBuffer.new(@mixer.width, @mixer.height, 1)
      texture = Jme::Texture::Texture2D.new(@mixer.width, @mixer.height,
                                            Jme::Texture::Image::Format::RGBA8)
      # Use linear filtering, we are effectively scaling the texture
      # during UYVY processing, and "nearest" looks terrible.
      texture.magFilter = Jme::Texture::Texture::MagFilter::Bilinear
      texture.minFilter = Jme::Texture::Texture::MinFilter::BilinearNoMipMaps
      texture.wrap = Jme::Texture::Texture::WrapMode::Clamp
      fbo.colorTexture = texture
      fbo.depthBuffer = DEPTH_FORMAT
      fbo
    end
    private :create_output_texture_fbo

    def create_uyvy_visual_context(render_manager, tpf, texture)
      # Half width because we are packing RGBA into UYVY
      width = @mixer.width / 2
      height = @mixer.height

      camera = Jme::Renderer::Camera.new(width, height)
      viewport = Jme::Renderer::ViewPort.new("EncodingViewport", camera)
      fbo = Jme::Texture::FrameBuffer.new(width, height, 1)
      fbo.colorBuffer = Jme::Texture::Image::Format::RGBA8
      viewport.outputFrameBuffer = fbo
      rootnode = Jme::Scene::Node.new("EncodingRoot")
      viewport.attachScene(rootnode)

      material = Jme::Material::Material.new(@mixer.asset_manager,
                                             'rendermix/MatDefs/UYVY/RGB2UYVY.j3md')
      material.setTexture('Texture', texture)

      quad = OrthoQuad.new(@mixer.asset_manager,
                           width, height, width, height,
                           material: material, flip_y: true,
                           clear_flags: [false, false, false],
                           name: 'EncodingQuad')

      context = VisualContext.new(render_manager, tpf, viewport, rootnode)
      quad.configure_context(context)
      context
    end
    private :create_uyvy_visual_context

    def audio_silence_buffer
      @audio_silence_buffer ||= @mixer.rawmedia_session.create_audio_buffer
    end
    private :audio_silence_buffer

    def visual_black_buffer
      unless @visual_black_buffer_pointer
        size = @visual_buffer_pointer.size
        @visual_black_buffer_pointer = FFI::MemoryPointer.new(size)
        0.step(size - 1, 4) do |i|
          # Fill with U Y V Y = 128 16 128 16
          @visual_black_buffer_pointer.put_uchar(i, 0x80)
          @visual_black_buffer_pointer.put_uchar(i + 1, 0x10)
          @visual_black_buffer_pointer.put_uchar(i + 2, 0x80)
          @visual_black_buffer_pointer.put_uchar(i + 3, 0x10)
        end
      end
      @visual_black_buffer_pointer
    end
    private :visual_black_buffer
  end
end
