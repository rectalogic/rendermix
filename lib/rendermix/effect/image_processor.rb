# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class ImageProcessor < VisualBase
      # Materials that need timing should accept a uniform with this name
      TIME_UNIFORM = 'time'

      # @param [String] matdef_name path to j3md material definition in asset
      # @param [Array<String>] texture_names array of texture uniform names
      #  in the material. These are in track order (i.e. the first texture
      #  name will be used for the first track etc.)
      def initialize(matdef_name, texture_names)
        super()
        @matdef_name = matdef_name
        @texture_names = texture_names
      end

      def on_rendering_prepare(context_manager, tracks)
        raise(InvalidMixError, "Material #@matdef_name does not have as many textures as tracks") unless tracks.length == @texture_names.length

        @material = Jme::Material::Material.new(mixer.asset_manager, @matdef_name)
        matdef = @material.materialDef
        @texture_names.each do |name|
          param = matdef.getMaterialParam(name)
          if not param or param.varType != Jme::Shader::VarType::Texture2D
            raise(InvalidMixError, "Material #@matdef_name missing texture uniform #{name}")
          end
        end

        @needs_time = !!matdef.getMaterialParam(TIME_UNIFORM)

        @quad = OrthoQuad.new(mixer.asset_manager,
                              mixer.width, mixer.height,
                              mixer.width, mixer.height,
                              material: @material, flip_y: false,
                              name: 'ImageProcessor')
        @configure_context = true
      end

      def on_visual_render(visual_context, track_visual_contexts, current_frame)
        if @configure_context
          @quad.configure_context(visual_context)
          @configure_context = false
        end

        if @needs_time
          @material.setFloat(TIME_UNIFORM, current_frame.to_f / duration)
        end

        @texture_names.each_with_index do |name, i|
          texture = track_visual_contexts[i] && track_visual_contexts[i].prepare_texture
          @material.setTexture(name, texture)
        end
      end

      def visual_context_released(context)
        @configure_context = true
      end

      def on_rendering_finished
        @quad = nil
        @material = nil
      end
    end
  end
end
