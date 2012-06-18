# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Mix
    class Image < Base
      #XXX we should store the actual "rendered area" coords on VisualContext - i.e. for an image that is scaled to "meet", we can store its visible region
      #XXX this can be used in some effects to extract and UV map only the visible portion of the texture - avoiding black/transparent border regions

      #XXX add panzoom keyframe interpolation support via OrthoQuad to this and Media

      def initialize(mixer, filename, duration)
        super(mixer, duration)
        @filename = filename
      end

      def visual_rendering_prepare(context_manager)
        # Don't flipY when loading, we flip via UV in OrthoQuad
        key = JmeAsset::TextureKey.new(@filename, false)
        key.generateMips = true
        begin
          # Temporarily register filesystem root so we can load textures
          # from anywhere
          mixer.asset_manager.registerLocator('/', JmeAssetPlugins::FileLocator.java_class)
          texture = mixer.asset_manager.loadTexture(key)
        ensure
          mixer.asset_manager.unregisterLocator('/', JmeAssetPlugins::FileLocator.java_class)
        end
        texture.magFilter = JmeTexture::Texture::MagFilter::Bilinear
        # This does mipmapping
        texture.minFilter = JmeTexture::Texture::MinFilter::Trilinear
        texture.wrap = JmeTexture::Texture::WrapMode::Clamp

        image = texture.image
        @quad = OrthoQuad.new(mixer.asset_manager, mixer.width, mixer.height,
                              image.width, image.height, name: 'Image')
        @quad.material.setTexture('Texture', texture)
        @configure_context = true
      end

      def on_visual_render(context_manager, current_frame)
        visual_context = context_manager.acquire_context(self)
        if @configure_context
          @quad.configure_context(visual_context)
          @configure_context = false
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
