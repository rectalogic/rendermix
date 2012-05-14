module RenderMix
  class ViewportPool
    MSAA_SAMPLES = 4

    def initialize(width, height)
      @viewports = []
      @viewports_3d = []
      @width = width
      @height = height
    end

    def allocate_viewport(need_3d)
      pool = need_3d ? @viewports_3d : @viewports
      return pool.pop unless pool.empty?

      camera = JmeRenderer::Camera.new(@width, @height)
      viewport = JmeRenderer::ViewPort.new("viewport", camera)
      # MSAA if 3d
      fbo = JmeTexture::FrameBuffer.new(@width, @height, need_3d ? MSAA_SAMPLES : 1)
      if need_3d
        #XXX should we be explicit? Depth32 etc.?
        fbo.setDepthBuffer(JmeTexture::Image::Format::Depth)
      end
      #XXX is this the best image format?
      tex = JmeTexture::Texture2D(@width, @height,
                                  JmeTexture::Image::Format::ABGR8)
      fbo.colorTexture = tex
      viewport.outputFrameBuffer = fbo
      viewport
    end

    def texture(viewport)
      viewport.outputFrameBuffer.colorBuffer.texture
    end

    def release_viewport(viewport, need_3d)
      if viewport
        if need_3d
          @viewports_3d << viewport
        else
          @viewports << viewport
        end
        viewport.clearScenes
      end
    end
  end
end
