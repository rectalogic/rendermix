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
      # Configure 1x1 offscreen pbuffer, we don't use this.
      # We render to FBO instead. On Linux, JME requests no alpha on
      # the Pbuffer and so we can't use it.
      settings.setResolution(1, 1)
    end

    def prepare
      # Half width because we are packing RGBA into UYVY
      width = @mixer.width / 2
      height = @mixer.height

      @encoding_visual_context =
        VisualContext.new(@mixer,
                          width: width, height: height,
                          clear_flags: [false, false, false],
                          depth: false, texture: false)

      @material = Jme::Material::Material.new(@mixer.render_system.asset_manager,
                                              'rendermix/MatDefs/UYVY/RGB2UYVY.j3md')

      quad = OrthoQuad.new(@mixer.render_system.asset_manager,
                           width, height, width, height,
                           material: @material, flip_y: true,
                           name: 'EncodingQuad')
      @encoding_visual_context.rootnode.attachChild(quad.quad)
    end

    def encode(audio_context, visual_context)
      audio = audio_context && audio_context.buffer
      @encoder.encode_audio(audio || audio_silence_buffer)

      @visual_byte_buffer.clear
      if visual_context
        texture = visual_context.render_scene
        @material.setTexture('Texture', texture)

        # Render UYVY quad
        @encoding_visual_context.render_scene
        # Read back the UYVY data
        @encoding_visual_context.read_framebuffer(@visual_byte_buffer)
        @encoder.encode_video(@visual_buffer_pointer, @visual_buffer_pointer.size)
      else
        @encoder.encode_video(visual_black_buffer, visual_black_buffer.size)
      end
    end

    def finish
      @encoder.destroy
    end

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
