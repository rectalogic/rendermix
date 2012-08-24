# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class VisualContext
    attr_reader :width
    attr_reader :height

    # @param [Jme::Renderer::RenderManager] render_manager
    # @param [Float] tpf time per frame
    # @param [Jme::Renderer::ViewPort] viewport
    # @param [Jme::Scene::Node] rootnode
    # @param [Jme::Texture::Texture2D] texture
    def initialize(render_manager, tpf, viewport, rootnode, texture=nil)
      @render_manager = render_manager
      @renderer = render_manager.renderer
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

    # @param [Jme::Post::SceneProcessor] processor
    #   {Jme::Post::FilterPostProcessor} should not contain any FXAA filters,
    #   and only one is supported.
    def add_scene_processor(processor)
      if processor.kind_of?(Jme::Post::FilterPostProcessor)
        raise(RuntimeError, 'FilterPostProcessor already set') if @fpp
        @fpp = processor
        @antialias_filter = nil
      end
      @viewport.addProcessor(processor)
    end

    # @param [Jme::Asset::AssetManager] asset_manager
    # @param [Jme::Post::Filter] filter FXAA filter or nil
    def set_antialias_filter(asset_manager, filter)
      if filter and not @antialias_filter
        @antialias_filter = filter
        # If FPP is already set on us, use it, otherwise create one.
        unless @fpp
          @fpp = Jme::Post::FilterPostProcessor.new(asset_manager)
          @viewport.addProcessor(@fpp)
        end
        @fpp.addFilter(@antialias_filter)
      elsif not filter and @antialias_filter
        @fpp.removeFilter(@antialias_filter)
        @antialias_filter = nil
      end
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

      @viewport.clearProcessors

      if @fpp and @antialias_filter
        @fpp.removeFilter(@antialias_filter)
        @fpp = nil
        @antialias_filter = nil
      end
    end

    def camera
      @viewport.camera
    end

    # Renders this context and returns the texture
    # @return [Jme::Texture::Texture2D]
    def prepare_texture
      @rootnode.updateLogicalState(@tpf)
      @rootnode.updateGeometricState

      @render_manager.renderViewPort(@viewport, @tpf)
      @texture
    end

    # @param [JavaNIO::ByteBuffer] buffer
    def read_framebuffer(buffer)
      @renderer.readFrameBuffer(@viewport.outputFrameBuffer, buffer)
    end

    @@buckets = {
      :gui => Jme::Renderer::Queue::RenderQueue::Bucket::Gui,
      :inherit => Jme::Renderer::Queue::RenderQueue::Bucket::Inherit,
      :opaque => Jme::Renderer::Queue::RenderQueue::Bucket::Opaque,
      :sky => Jme::Renderer::Queue::RenderQueue::Bucket::Sky,
      :translucent => Jme::Renderer::Queue::RenderQueue::Bucket::Translucent,
      :transparent => Jme::Renderer::Queue::RenderQueue::Bucket::Transparent
    }
  end
end
