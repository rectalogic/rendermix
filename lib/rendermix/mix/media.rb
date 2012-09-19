# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Media < Base
      # @param [Mixer] mixer
      # @param [String] filename the media file to decode
      # @param [Hash] opts decoding options
      # @option opts [Float] :volume (1.0) exponential volume to decode audio, 0..1
      # @option opts [Fixnum] :start_frame (0) starting video frame
      # @option opts [Boolean] :discard_audio (false) ignore media audio
      # @option opts [Boolean] :discard_video (false) ignore media video
      # @option opts [Fixnum] :duration override intrinsic media duration
      # @option opts [Fixnum] :pre_freeze (0) freeze the initial frame for
      #   this many frames. The effective duration is increased by this
      #   amount.
      # @option opts [Fixnum] :post_freeze (0) freeze the final frame for
      #   this many frames. The effective duration is increased by this
      #   amount.
      # @option opts [PanZoom::Timeline] :panzoom panzoom timeline (optional)
      def initialize(mixer, filename, opts={})
        opts.validate_keys(:volume, :start_frame, :discard_audio, :discard_video, :duration, :pre_freeze, :post_freeze, :panzoom)
        volume = opts.fetch(:volume, 1.0)
        start_frame = opts.fetch(:start_frame, 0.0)
        @decoder = RawMedia::Decoder.new(filename, mixer.rawmedia_session,
                                         mixer.width, mixer.height,
                                         volume: volume,
                                         start_frame: start_frame,
                                         discard_audio: opts[:discard_audio],
                                         discard_video: opts[:discard_video])
        pre_freeze = opts.fetch(:pre_freeze, 0)
        post_freeze = opts.fetch(:post_freeze, 0)
        media_duration = opts.fetch(:duration, @decoder.duration)
        media_duration = @decoder.duration if media_duration > @decoder.duration
        super(mixer, pre_freeze + media_duration + post_freeze)
        @panzoom = opts[:panzoom]
        if pre_freeze > 0 or post_freeze > 0
          @freezer = Freezer.new(pre_freeze, post_freeze, media_duration)
        end
      end

      def audio_rendering_prepare(context_manager)
        return unless @decoder.has_audio?
        @audio_context = AudioContext.new(mixer)
      end

      def on_audio_render(context_manager, current_frame)
        return unless (@decoder.has_audio? and (not @freezer or not @freezer.freezing?(current_frame)))
        context_manager.context = @audio_context
        @decoder.decode_audio(@audio_context.buffer)
      end

      def audio_rendering_finished
        @audio_finished = true
        @audio_context = nil
        cleanup
      end

      def visual_rendering_prepare(context_manager)
        return unless @decoder.has_video?
        texture = Jme::Texture::Texture2D.new
        # No filtering, UYVY shader needs the real pixels
        texture.magFilter = Jme::Texture::Texture::MagFilter::Nearest
        texture.minFilter = Jme::Texture::Texture::MinFilter::NearestNoMipMaps
        texture.wrap = Jme::Texture::Texture::WrapMode::Clamp

        @image = Jme::Texture::Image.new
        @image.format = Jme::Texture::Image::Format::RGBA8
        texture.setImage(@image)

        # Create UYVY decoding material
        @material = Jme::Material::Material.new(mixer.render_system.asset_manager,
                                               'rendermix/MatDefs/UYVY/UYVY2RGB.j3md')
        @material.setTexture('Texture', texture)

        @visual_context = VisualContext.new(mixer,
                                            depth: false,
                                            clear_flags: [true, false, false])
      end

      def on_visual_render(context_manager, current_frame)
        return unless @decoder.has_video?
        context_manager.context = @visual_context

        should_render = (not @freezer or @freezer.render?(current_frame))

        result = should_render ? @decoder.decode_video : 0

        # Only reset the texture if something new decoded
        if result > 0
          # Image is half width since we are stuffing UYVY in RGBA
          @image.width = @decoder.width / 2
          @image.height = @decoder.height
          @image.data = @decoder.video_byte_buffer

          # We have to defer quad creation until we decode the first frame,
          # so we have the video dimensions
          unless @quad
            @quad = OrthoQuad.new(mixer.render_system.asset_manager,
                                  mixer.width, mixer.height,
                                  @decoder.width, @decoder.height,
                                  material: @material, name: 'Media',
                                  fit: @panzoom ? @panzoom.fit : "meet")
            @visual_context.rootnode.attachChild(@quad.quad)
            @material = nil
          end
        end

        if @panzoom and should_render
          time = @freezer ? @freezer.current_time : frame_to_time(current_frame, @decoder.duration)
          @panzoom.panzoom(time, @quad)
        end
      end

      def visual_rendering_finished
        @image = nil
        @quad = nil
        @visual_context = nil

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
