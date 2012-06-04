# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  # Manages orthographic fullscreen screen-aligned quad
  class OrthoQuad
    attr_reader :material

    # _opts_
    #  :flip_y - True if image should be flipped vertically. Default true.
    #  :clear_flags - Array of boolean [color, depth, stencil]. Default [true,false,false]
    #  :material - JmeMaterial::Material to use. A default material will
    #    be used if not set. The default has a Texture param named 'Texture'
    def initialize(visual_context, asset_manager, image_width, image_height, opts={})
      @image_width = image_width
      @image_height = image_height
      @context_width = visual_context.width
      @context_height = visual_context.height

      visual_context.camera.parallelProjection = true

      clear_flags = opts.fetch(:clear_flags, [true, false, false])
      visual_context.set_clear_flags(*clear_flags)
      visual_context.render_bucket = :gui

      flip_y = opts.fetch(:flip_y, true)
      quad = JmeShape::Quad.new(@image_width, @image_height, flip_y)
      @quad = JmeScene::Geometry.new("quad", quad)
      @quad.cullHint = JmeScene::Spatial::CullHint::Never
      
      @material = opts[:material]
      unless @material
        @material = JmeMaterial::Material.new(asset_manager,
                                              'Common/MatDefs/Gui/Gui.j3md')
        @material.setColor('Color', JmeMath::ColorRGBA::White)
      end
      @material.additionalRenderState.depthTest = false
      @material.additionalRenderState.depthWrite = false
      #XXX set blendMode if we want to use alpha from texture - caller can do that on provided material
      @quad.material = @material

      visual_context.attach_child(@quad)

      scales = [@context_width / @image_width.to_f,
                @context_height / @image_height.to_f]
      @meet_scale = scales.min
      @fill_scale = scales.max
      @auto_scale = @fill_scale >= 1.5 ? @meet_scale : @fill_scale

      panzoom
    end

    # _scale_ amount to scale beyond the prescale for _fit_
    # _tx_ _ty_ Amount to translate center. Visual context is normalized to
    #  1.0 width and height. So [0,0] is no translation (centered),
    #  [1,1] would translate the upper left corner of the visual context
    #  to the lower right corner.
    # _fit_
    #  :meet - prescale to fit within visual context
    #  :fill - prescale to fully fill visual context (may be scaled larger)
    #  :auto - choose :meet or :fill whichever is a closer fit
    def panzoom(scale=1.0, tx=0, ty=0, fit=:meet)
      case fit
      when :meet
        scale *= @meet_scale
      when :fill
        scale *= @fill_scale
      when :auto
        scale *= @auto_scale
      else
        raise(InvalidMixError, "Invalid panzoom fit value #{fit}")
      end

      tx *= @context_width
      ty *= @context_height

      x = (@context_width - @image_width * scale) / 2.0 + tx
      y = (@context_height - @image_height * scale) / 2.0 + ty

      @quad.setLocalTranslation(x, y, 0)
      @quad.setLocalScale(scale, scale, 1.0)
    end
  end
end
