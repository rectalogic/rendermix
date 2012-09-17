# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    # Applies a material to a fullscreen quad.
    # The material should apply a GLSL filter or transition to the supplied
    # texture tracks.
    class ImageProcessor < VisualBase
      # Materials that need timing should accept a uniform with this name
      TIME_UNIFORM = 'Time'

      # @param [String] material_asset asset path to j3m material file
      # @param [Array<String>] texture_names array of material uniform names
      #   for each texture. These are in track order (i.e. the first texture
      #   name will be used for the first track etc.)
      def initialize(material_asset, texture_names=[])
        super()
        @material_asset = material_asset
        @texture_names = texture_names
      end

      def on_rendering_prepare(context_manager)
        @material = mixer.render_system.asset_manager.loadMaterial(@material_asset)
        matdef = @material.materialDef
        @texture_names.each do |name|
          param = matdef.getMaterialParam(name)
          if not param or param.varType != Jme::Shader::VarType::Texture2D
            raise(InvalidMixError, "Material #@material_asset missing texture uniform #{name}")
          end
        end

        @needs_time = !!matdef.getMaterialParam(TIME_UNIFORM)

        quad = OrthoQuad.new(mixer.render_system.asset_manager,
                             mixer.width, mixer.height,
                             mixer.width, mixer.height,
                             material: @material, flip_y: false,
                             name: 'ImageProcessor')

        @scene_renderer = SceneRenderer.new(mixer,
                                            depth: false,
                                            clear_flags: [true, false, false])
        @scene_renderer.rootnode.attachChild(quad.quad)
      end

      def on_visual_render(context_manager, visual_context, track_visual_contexts)
        visual_context.scene_renderer = @scene_renderer

        if @needs_time
          @material.setFloat(TIME_UNIFORM, current_time)
        end

        #XXX we should check that all remaining track_visual_contexts are nil - i.e. don't want to be rendering tracks that aren't consumed
        @texture_names.each_with_index do |name, i|
          vc = track_visual_contexts[i]
          texture = vc.scene_renderer.render_scene if vc && vc.scene_renderer
          @material.setTexture(name, texture)
        end
      end

      def on_rendering_finished
        @material = nil
        @scene_renderer = nil
      end
    end
  end
end
