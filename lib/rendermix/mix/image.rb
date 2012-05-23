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
        #XXX set texture wrap mode, mipmaps etc. - transparent border?
        # Don't flipY when loading, we flip via UV in OrthoQuad
        key = JmeAsset::TextureKey.new(@filename, false)
        key.generateMips = true
        @texture = mixer.asset_manager.loadTexture(key)
        @texture.magFilter = JmeTexture::Texture::MagFilter::Bilinear
        # This does mipmapping
        @texture.minFilter = JmeTexture::Texture::MinFilter::Trilinear
      end

      def on_render_visual(context_manager, current_frame, renderer_tracks)
        visual_context = context_manager.acquire_context(self)
        unless @quad
          image = @texture.image
          @quad = OrthoQuad.new(visual_context, mixer.asset_manager,
                                image.width, image.height)
          @quad.material.setTexture('Texture', @texture)
        end
      end

      def visual_context_released(context)
        @quad = nil
      end

      def visual_rendering_finished
        @texture = nil
      end
    end
  end
end
