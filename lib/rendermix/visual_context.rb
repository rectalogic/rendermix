# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class VisualContext
    attr_reader :width
    attr_reader :height

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
      @camera_prototype = viewport.camera.clone
      @width = @camera_prototype.width
      @height = @camera_prototype.height
      reset
    end

    def attach_child(spatial)
      @rootnode.attachChild(spatial)
    end

    def set_clear_flags(color, depth, stencil)
      @viewport.setClearFlags(color, depth, stencil)
    end

    def render_bucket=(bucket)
      @rootnode.queueBucket = @@buckets.fetch(bucket)
    end

    def render_bucket
      @@buckets.invert.fetch(@rootnode.localQueueBucket)
    end

    def reset
      @rootnode.detachAllChildren
      # User may have set Texture properties (wrap etc.),
      # so reset to a pristine clone.
      # Cloning shares the Image, and the Image is the native GL texture object.
      @texture = @texture_prototype.clone if @texture_prototype
      # Reset viewport camera to original state
      @viewport.camera.copyFrom(@camera_prototype)
      set_clear_flags(true, true, true)
      self.render_bucket = :inherit
    end

    def camera
      @viewport.camera
    end

    # Renders this context and returns the texture
    # @return [JmeTexture::Texture2D]
    def prepare_texture
      @rootnode.updateLogicalState(@tpf)
      @rootnode.updateGeometricState

      @render_manager.renderViewPort(@viewport, @tpf)
      @texture
    end

    @@buckets = {
      :gui => JmeRendererQueue::RenderQueue::Bucket::Gui,
      :inherit => JmeRendererQueue::RenderQueue::Bucket::Inherit,
      :opaque => JmeRendererQueue::RenderQueue::Bucket::Opaque,
      :sky => JmeRendererQueue::RenderQueue::Bucket::Sky,
      :translucent => JmeRendererQueue::RenderQueue::Bucket::Translucent,
      :transparent => JmeRendererQueue::RenderQueue::Bucket::Transparent
    }
  end
end
