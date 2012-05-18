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
end
