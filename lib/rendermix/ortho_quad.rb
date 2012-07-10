# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  # Manages orthographic fullscreen screen-aligned quad
  class OrthoQuad
    # @return [Jme::Material::Material]
    attr_reader :material

    # @param [Hash] opts
    # @option opts [Boolean] :flip_y rrue if image should be flipped vertically. Default true.
    # @option opts [Array<Boolean>] :clear_flags array of boolean [color, depth, stencil]. Default [true,false,false]
    # @option opts [Jme::Material::Material] :material material to use.
    #   A default material will be used if not set.
    #   The default has a Texture param named 'Texture'
    # @option opts [String] :name debug name for geometry
    # @option opts [Symbol] :fit panzoom fit semantics:
    #   :meet prescale to fit within visual context,
    #   :fill prescale to fully fill visual context (may be scaled larger),
    #   :auto choose :meet or :fill whichever is a closer fit
    def initialize(asset_manager, quad_width, quad_height, image_width, image_height, opts={})
      opts.assert_valid_keys(:flip_y, :clear_flags, :material, :name, :fit)
      @image_width = image_width
      @image_height = image_height
      @quad_width = quad_width
      @quad_height = quad_height

      @clear_flags = opts.fetch(:clear_flags, [true, false, false])

      flip_y = opts.fetch(:flip_y, true)
      quad = Jme::Shape::Quad.new(@image_width, @image_height, flip_y)
      @quad = Jme::Scene::Geometry.new(opts.fetch(:name, "quad"), quad)
      @quad.cullHint = Jme::Scene::Spatial::CullHint::Never
      
      @material = opts[:material]
      unless @material
        @material = Jme::Material::Material.new(asset_manager,
                                                'Common/MatDefs/Gui/Gui.j3md')
        @material.setColor('Color', Jme::Math::ColorRGBA::White)
      end
      @material.additionalRenderState.depthTest = false
      @material.additionalRenderState.depthWrite = false
      #XXX set blendMode if we want to use alpha from texture - caller can do that on provided material
      @quad.material = @material

      scales = [@quad_width / @image_width.to_f,
                @quad_height / @image_height.to_f]
      meet_scale = scales.min
      fill_scale = scales.max
      auto_scale = fill_scale >= 1.5 ? meet_scale : fill_scale

      fit = opts.fetch(:fit, :meet)
      case fit
      when :meet
        @fit_scale = meet_scale
      when :fill
        @fit_scale = fill_scale
      when :auto
        @fit_scale = fill_scale >= 1.5 ? meet_scale : fill_scale
      else
        raise(InvalidMixError, "Invalid panzoom fit value #{fit}")
      end

      panzoom
    end

    # @param [VisualContext] visual_context configure and attach this quad
    #   as a child of the context
    def configure_context(visual_context)
      visual_context.camera.parallelProjection = true

      visual_context.set_clear_flags(*@clear_flags)
      visual_context.render_bucket = :gui

      visual_context.attach_child(@quad)
    end

    # @param [Float] scale amount to scale beyond the prescale for fit
    # @param [Float] tx Amount to translate center. Visual context is
    #   normalized to 1.0 width and height.
    #   So (0,0) is no translation (centered),
    #   (1,1) would translate the upper left corner of the visual context
    #   to the lower right corner.
    # @param [Float] ty (see tx)
    def panzoom(scale=1.0, tx=0, ty=0)
      scale *= @fit_scale
      tx *= @quad_width
      ty *= @quad_height

      x = (@quad_width - @image_width * scale) / 2.0 + tx
      y = (@quad_height - @image_height * scale) / 2.0 + ty

      @quad.setLocalTranslation(x, y, 0)
      @quad.setLocalScale(scale, scale, 1.0)
    end
  end
end
