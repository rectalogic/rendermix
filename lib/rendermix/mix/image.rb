module RenderMix
  module Mix
    class Image < Base
      def initialize(filename, duration)
        super(duration)
        #XXX create JME Texture
        #XXX need to use AssetManager - pass it in here, and add path to it, load, then remove
        @texture = JmeTexture::Texture2D.new(JmeTexture::Image.new())
        #XXX set wrap mode, mipmaps etc. - transparent border?
      end

      def on_render_visual(context_manager, current_frame, renderer_tracks)
        visual_context = context_manager.acquire_context(self)
      end

      def visual_context_released
        #XXX cleanup any context specific state
      end

      def visual_rendering_complete
        @texture = nil
      end
    end
  end
end
