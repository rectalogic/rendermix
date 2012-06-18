# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    class ImageProcessor < VisualBase
      # Materials that need timing should accept a uniform with this name
      TIME_UNIFORM = 'time'

      # @param [String] asset_location filesystem path to asset
      #  root directory or zip file
      # @param [String] matdef_name path to j3md material definition in asset
      # @param [Array<String>] texture_names array of texture uniform names
      #  in the material. These are in track order (i.e. the first texture
      #  name will be used for the first track etc.)
      def initialize(asset_location, matdef_name, texture_names)
        super()
        raise(InvalidMixError, "Effect asset location does not exist") unless File.exist?(asset_location)
        @asset_location = asset_location
        @matdef_name = matdef_name
        @texture_names = texture_names
      end

      def on_rendering_prepare(context_manager, tracks)
        raise(InvalidMixError, "Material #@matdef_name does not have as many textures as tracks") unless tracks.length == @texture_names.length

        locator_class = File.directory?(@asset_location) ?
          JmeAssetPlugins::FileLocator.java_class :
          JmeAssetPlugins::ZipLocator.java_class
        mixer.asset_manager.registerLocator(@asset_location, locator_class)

        @material = JmeMaterial::Material.new(mixer.asset_manager, @matdef_name)
        matdef = @material.materialDef
        @texture_names.each do |name|
          param = matdef.getMaterialParam(name)
          if not param or param.varType != JmeShader::VarType::Texture2D
            raise(InvalidMixError, "Material #@matdef_name missing texture uniform #{name}")
          end
        end

        # Preload before we unregister our locator
        @material.preload(context_manager.render_manager)

        @needs_time = !!matdef.getMaterialParam(TIME_UNIFORM)

        @quad = OrthoQuad.new(mixer.asset_manager,
                              mixer.width, mixer.height,
                              mixer.width, mixer.height,
                              material: @material, flip_y: false,
                              name: 'ImageProcessor')
        @configure_context = true
      ensure
        mixer.asset_manager.unregisterLocator(@asset_location, locator_class)
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
          # Setting texture to nil is only valid if it has already been set
          if texture or @material.getTextureParam(name)
            @material.setTexture(name, texture)
          end
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
