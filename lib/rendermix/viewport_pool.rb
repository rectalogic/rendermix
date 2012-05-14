module RenderMix
  class ViewportPool
    def initialize(width, height)
      @viewports = []
      @width = width
      @height = height
    end

    def allocate_viewport
      return @viewports.pop unless @viewports.empty?

      camera = JmeRenderer::Camera.new(@width, @height)
      viewport = JmeRenderer::ViewPort.new("viewport", camera)
      viewport.setClearFlags(true, true, true)
      fbo = JmeTexture::FrameBuffer.new(@width, @height, MSAA_SAMPLES)
      fbo.setDepthBuffer(DEPTH_FORMAT)
      #XXX is this the best image format?
      tex = JmeTexture::Texture2D(@width, @height,
                                  JmeTexture::Image::Format::ABGR8)
      fbo.colorTexture = tex
      viewport.outputFrameBuffer = fbo
      viewport
    end

    def texture(viewport)
      #XXX what about wrap/filter/mipmap of this texture? can caller reset those? when do they get unset? should we clone()?
      viewport.outputFrameBuffer.colorBuffer.texture
    end

    def release_viewport(viewport)
      if viewport
        @viewports << viewport
        viewport.clearScenes
      end
    end
  end
end
