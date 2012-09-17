# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  class SceneRenderer
    # @return [Jme::Scene::Node]
    attr_reader :rootnode
    # @return [Jme::Renderer::Camera]
    attr_reader :camera
    # @return [Jme::Renderer::ViewPort]
    attr_reader :viewport
    # @return [Jme::Texture::Texture2D]
    attr_reader :texture

    # @param [Mixer] mixer
    # @param [Hash] opts options
    # @option opts [Fixnum] :width viewport width, defaults to mixer width
    # @option opts [Fixnum] :height viewport height, defaults to mixer height
    # @option opts [Array<Boolean>] :clear_flags array of
    #   (color, depth, stencil) flags
    # @options opts [Boolean] :depth (false) true if depth buffer is required
    # @options opts [Boolean] :texture (true) true if should render to texture
    def initialize(mixer, opts={})
      #XXX fixup - allow camera to be passed in
      opts.validate_keys(:clear_flags, :depth, :width, :height, :texture)
      @render_manager = mixer.render_system.render_manager
      @renderer = @render_manager.renderer
      @tpf = mixer.render_system.timer.timePerFrame

      width = opts.fetch(:width, mixer.width)
      height = opts.fetch(:height, mixer.height)

      @camera = Jme::Renderer::Camera.new(width, height)
      @camera.setFrustumPerspective(45, width / height.to_f, 1, 1000)
      @camera.location = Jme::Math::Vector3f.new(0, 0, 10)
      @camera.lookAt(Jme::Math::Vector3f::ZERO, Jme::Math::Vector3f::UNIT_Y)

      @viewport = Jme::Renderer::ViewPort.new("Viewport", @camera)
      @viewport.setClearFlags(*opts[:clear_flags]) if opts.has_key?(:clear_flags)
      fbo = Jme::Texture::FrameBuffer.new(width, height, 1)
      fbo.setDepthBuffer(DEPTH_FORMAT) if opts[:depth]
      if opts.fetch(:texture, true)
        @texture = Jme::Texture::Texture2D.new(width, height,
                                               Jme::Texture::Image::Format::RGBA8)
        # Don't generate mipmaps
        @texture.magFilter = Jme::Texture::Texture::MagFilter::Bilinear
        @texture.minFilter = Jme::Texture::Texture::MinFilter::BilinearNoMipMaps
        @texture.wrap = Jme::Texture::Texture::WrapMode::Clamp
        fbo.colorTexture = @texture
      else
        fbo.colorBuffer = Jme::Texture::Image::Format::RGBA8
      end
      @viewport.outputFrameBuffer = fbo

      @rootnode = Jme::Scene::Node.new("SceneRoot")
      @viewport.attachScene(@rootnode)
    end

    # @return [Jme::Texture::Texture]
    def render_scene
      @rootnode.updateLogicalState(@tpf)
      @rootnode.updateGeometricState

      @render_manager.renderViewPort(@viewport, @tpf)
      @texture
    end

    # @param [JavaNIO::ByteBuffer] buffer
    def read_framebuffer(buffer)
      @renderer.readFrameBuffer(@viewport.outputFrameBuffer, buffer)
    end

    # @param [Jme::Texture::FrameBuffer] output
    def copy_framebuffer(output=nil)
      @renderer.copyFrameBuffer(@viewport.outputFrameBuffer, output, false)
    end
  end
end
