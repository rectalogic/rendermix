module RenderMix
  class VisualContext
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
      @texture_prototype = texture
      reset
    end

    def reset
      @rootnode.detachAllChildren
      # User may have set Texture properties (wrap etc.),
      # so reset to a pristine clone.
      # Cloning shares the Image, and the Image is the native GL texture object.
      @texture = @texture_prototype.clone if @texture_prototype
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
