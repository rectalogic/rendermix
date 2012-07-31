# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Image < Base
      #XXX we should store the actual "rendered area" coords on VisualContext - i.e. for an image that is scaled to "meet", we can store its visible region
      #XXX this can be used in some effects to extract and UV map only the visible portion of the texture - avoiding black/transparent border regions

      # @param [Mixer] mixer
      # @param [String] filename the image file
      # @param [Hash] opts options
      # @option opts [Fixnum] :duration set image duration (required)
      # @option opts [Fixnum] :pre_freeze (0) freeze the initial frame for
      #   this many frames. The effective duration is increased by this
      #   amount.
      # @option opts [Fixnum] :post_freeze (0) freeze the final frame for
      #   this many frames. The effective duration is increased by this
      #   amount.
      # @option opts [PanZoom::Timeline] :panzoom panzoom timeline (optional)
      def initialize(mixer, filename, opts={})
        opts.validate_keys(:duration, :pre_freeze, :post_freeze, :panzoom)
        @image_duration = opts.fetch(:duration) rescue raise(InvalidMixError, "Image requires duration")
        pre_freeze = opts.fetch(:pre_freeze, 0)
        post_freeze = opts.fetch(:post_freeze, 0)
        super(mixer, pre_freeze + @image_duration + post_freeze)
        @filename = filename
        @panzoom = opts[:panzoom]
        if pre_freeze > 0 or post_freeze > 0
          @freezer = Freezer.new(pre_freeze, post_freeze, @image_duration)
        end
      end

      def visual_rendering_prepare(context_manager)
        # Don't flipY when loading, we flip via UV in OrthoQuad
        key = Jme::Asset::TextureKey.new(@filename, false)
        key.generateMips = true
        begin
          # Temporarily register filesystem root so we can load textures
          # from anywhere
          mixer.asset_manager.registerLocator('/', Jme::Asset::Plugins::FileLocator.java_class)
          texture = mixer.asset_manager.loadTexture(key)
        ensure
          mixer.asset_manager.unregisterLocator('/', Jme::Asset::Plugins::FileLocator.java_class)
        end
        texture.magFilter = Jme::Texture::Texture::MagFilter::Bilinear
        # This does mipmapping
        texture.minFilter = Jme::Texture::Texture::MinFilter::Trilinear
        texture.wrap = Jme::Texture::Texture::WrapMode::Clamp

        image = texture.image
        @quad = OrthoQuad.new(mixer.asset_manager, mixer.width, mixer.height,
                              image.width, image.height, name: 'Image',
                              fit: @panzoom ? @panzoom.fit : "meet")
        @quad.material.setTexture('Texture', texture)
        @configure_context = true
      end

      def on_visual_render(context_manager, current_frame)
        visual_context = context_manager.acquire_context(self)
        if @configure_context
          @quad.configure_context(visual_context)
          @configure_context = false
        end

        if (@panzoom and (not @freezer or @freezer.render?(current_frame)))
          time = @freezer ? @freezer.current_time : frame_to_time(current_frame, @image_duration)
          @panzoom.panzoom(time, @quad)
        end
      end

      def visual_context_released(context)
        @configure_context = true
      end

      def visual_rendering_finished
        @quad = nil
      end
    end
  end
end
