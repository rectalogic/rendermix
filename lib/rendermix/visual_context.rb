module RenderMix
  class VisualContext
    attr_reader :viewport
    attr_reader :rootnode
    attr_reader :texture

    def initialize(viewport, rootnode, texture)
      @viewport = viewport
      @rootnode = rootnode
      @texture = texture
    end

    def camera
      @viewport.camera
    end

    def reset
      @rootnode.detachAllChildren
    end
  end

  class PooledVisualContext < VisualContext
    def initialize(width, height)
      camera = JmeRenderer::Camera.new(width, height)
      viewport = JmeRenderer::ViewPort.new("viewport", camera)
      viewport.setClearFlags(true, true, true)
      fbo = JmeTexture::FrameBuffer.new(width, height, MSAA_SAMPLES)
      fbo.setDepthBuffer(DEPTH_FORMAT)
      #XXX is this the best image format?
      #XXX what about wrap/filter/mipmap of this texture? can caller reset those? when do they get unset? should we clone()?
      texture = JmeTexture::Texture2D(width, height,
                                      JmeTexture::Image::Format::ABGR8)
      fbo.colorTexture = texture
      viewport.outputFrameBuffer = fbo

      rootnode = JmeScene::Node.new("Root")
      viewport.attachScene(rootnode)
      super(viewport, rootnode, texture)
    end
  end

  class VisualContextPool
    def initialize(width, height)
      @contexts = []
      @width = width
      @height = height
    end

    def allocate_context
      return @contexts.pop unless @contexts.empty?
      PooledVisualContext.new(@width, @height)
    end

    def release_context(context)
      if context
        @contexts << context
        context.reset
      end
    end
  end
end
