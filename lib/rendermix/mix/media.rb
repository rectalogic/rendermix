module RenderMix
  module Mix
    class Media < Base
      #XXX need to deal with "freezing" and panzoom

      # @param [Mixer] mixer
      # @param [String] filename the media file to decode
      # @param [Hash] opts decoding options
      # @option opts [Float] :volume exponential volume to decode audio, 0..1, default 1.0
      # @option opts [Fixnum] :start_frame starting video frame, default 0
      # @option opts [Fixnum] :duration override intrinsic media duration
      def initialize(mixer, filename, opts={})
        volume = opts.fetch(:volume, 1.0)
        start_frame = opts.fetch(:start_frame, 0.0)
        @decoder = RawMedia::Decoder.new(filename, mixer.rawmedia_session,
                                         mixer.width, mixer.height,
                                         volume: volume,
                                         start_frame: start_frame)
        duration = opts[:duration] || @decoder.duration
        super(mixer, duration)
      end

      def on_audio_render(context_manager, current_frame, renderer_tracks)
        return unless @decoder.has_audio?
        audio_context = context_manager.acquire_context(self)
        @decoder.decode_audio(audio_context.buffer)
      end

      def audio_rendering_finished
        @audio_finished = true
        cleanup
      end

      def visual_rendering_prepare(context_manager)
        return unless @decoder.has_video?
        @texture = JmeTexture::Texture2D.new
        @texture.magFilter = JmeTexture::Texture::MagFilter::Nearest
        @texture.minFilter = JmeTexture::Texture::MinFilter::NearestNoMipMaps
        @texture.wrap = JmeTexture::Texture::WrapMode::Clamp

        # Create UYVY decoding material
        @material = JmeMaterial::Material.new(mixer.asset_manager,
                                              'rendermix/MatDefs/UYVY/DecodeUYVY.j3md')
        @material.setTexture('Texture', @texture)
      end

      def on_visual_render(context_manager, current_frame, renderer_tracks)
        return unless @decoder.has_video?
        visual_context = context_manager.acquire_context(self)
        result = @decoder.decode_video
        unless @quad
          @quad = OrthoQuad.new(visual_context, mixer.asset_manager,
                                @decoder.width, @decoder.height,
                                material: @material)
        end
        # Only reset the texture if something new decoded
        if result > 0
          # Image is half width since we are stuffing UYVY in RGBA
          image = JmeTexture::Image.new(JmeTexture::Image::Format::RGBA8,
                                        @decoder.width / 2, @decoder.height,
                                        @decoder.video_byte_buffer)
          @texture.setImage(image)
        end
      end

      def visual_context_released(context)
        @quad = nil
      end

      def visual_rendering_finished
        @texture = nil
        @material = nil

        @visual_finished = true
        cleanup
      end

      def cleanup
        @decoder.destroy if @audio_finished and @visual_finished
      end
      private :cleanup
    end
  end
end
