module RenderMix
  class VisualContext
    attr_reader :viewport
    attr_reader :rootnode

    # _render_manager_ JMERenderer::RenderManager
    # _tpf_ Float time per frame
    # _viewport_ JMERenderer::ViewPort
    # _rootnode_ JMEScene::Node
    # _texture_ JMETexture::Texture2D
    def initialize(render_manager, tpf, viewport, rootnode, texture=nil)
      @render_manager = render_manager
      @tpf = tpf
      @viewport = viewport
      @rootnode = rootnode
      @texture = texture
    end

    def reset
      @rootnode.detachAllChildren
    end

    def camera
      @viewport.camera
    end

    def prepare_texture
      @rootnode.updateLogicalState(@tpf)
      @rootnode.updateGeometricState

      #XXX the user of the texture should call this - yes, so Effect will render each input to texture before using - and toplevel app will be responsible for rendring main context
      @render_manager.renderViewPort(@viewport, @tpf)
      @texture
    end
  end

  class VisualContextPool
    def initialize(render_manager, width, height, tpf)
      @contexts = []
      @render_manager = render_manager
      @width = width
      @height = height
      @tpf = tpf
    end

    def acquire_context
      return @contexts.pop unless @contexts.empty?
      create_context
    end

    def release_context(context)
      if context
        @contexts << context
        reset_context(context)
      end
    end

    def reset_context(context)
      context.reset
    end

    def create_context
      camera = JmeRenderer::Camera.new(@width, @height)
      viewport = JmeRenderer::ViewPort.new("viewport", camera)
      viewport.setClearFlags(true, true, true)
      fbo = JmeTexture::FrameBuffer.new(@width, @height, MSAA_SAMPLES)
      fbo.setDepthBuffer(DEPTH_FORMAT)
      #XXX is this the best image format?
      #XXX what about wrap/filter/mipmap of this texture? can caller reset those? when do they get unset? should we clone()?
      texture = JmeTexture::Texture2D(@width, @height,
                                      JmeTexture::Image::Format::ABGR8)
      fbo.colorTexture = texture
      viewport.outputFrameBuffer = fbo

      rootnode = JmeScene::Node.new("Root")
      viewport.attachScene(rootnode)

      VisualContext.new(@render_manager, @tpf, viewport, rootnode, texture)
    end
    private :create_context
  end
end
