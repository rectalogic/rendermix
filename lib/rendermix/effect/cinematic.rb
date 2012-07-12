# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

=begin
XXX text texture - need to define text (dimensions, colors, fonts etc.)
XXX also need parameters passed in like actual text string
XXX text texture name should be defined as above, then separate mapping of text definition to that texture name
=end

module RenderMix
  module Effect
    # A cinematic effect is typically a 3D animation, with texture
    # tracks applied to surface materials in the models.
    class Cinematic < VisualBase
      # @example Manifest JSON format:
      #   {
      #       "scenes" : [ "<asset-path-to-j3o>", ... ],
      #       "textures" : {
      #           "<TextureName>" : { "<GeometryName>" : "<UniformName>" }, ... 
      #       },
      #       "camera" : "<asset-path-to-camera-animation-json>"
      #   }
      #
      # "UniformName" is the name of a texture uniform on the
      # Jme::Material::Material associated with the Jme::Scene::Geometry
      # named "GeomtryName"
      # @param [String] manifest_asset asset path to manifest JSON
      # @param [Array<String>] texture_names array of texture names
      #   from the manifest. These are in track order (i.e. the first texture
      #   name will be used for the first track etc.)
      def initialize(manifest_asset, texture_names)
        super()
        @manifest_asset = manifest_asset
        @texture_names = texture_names
      end

      def on_rendering_prepare(context_manager, tracks)
        raise(InvalidMixError, "Cinematic for #@manifest_asset does not have as many textures as tracks") unless tracks.length == @texture_names.length

        # Load manifest JSON
        manifest = Asset::JSONLoader.load(mixer.asset_manager, @manifest_asset)
        manifest.validate_keys("scenes", "textures", "camera")

        # Attach all model files to root node
        @root_node = Jme::Scene::Node.new("Cinematic")
        scenes = manifest.fetch('scenes') rescue raise(InvalidMixError, "Missing scenes key for #@manifest_asset")
        scenes.each do |scene|
          model = mixer.asset_manager.loadModel(scene)
          @root_node.attachChild(model)
        end

        textures = manifest.fetch('textures') rescue raise(InvalidMixError, "Missing textures key for #@manifest_asset")
        @uniform_materials = uniform_materials(textures)

        camera_asset = manifest.fetch('camera') rescue raise(InvalidMixError, "Missing camera animation for #@manifest_asset")
        animation = Asset::JSONLoader.load(mixer.asset_manager, camera_asset)
        @camera_animation = CameraAnimation.new(animation, mixer.width / mixer.height.to_f) rescue raise(InvalidMixError, "Camera animation corrupt #{camera_asset}")

        @configure_context = true
      end

      # Map each texture name to its Material and Uniform.
      # @return [Array<UniformMaterial>] build an array of UniformMaterial
      def uniform_materials(manifest_textures)
        @texture_names.collect do |texture_name|
          map = manifest_textures.fetch(texture_name) rescue raise(InvalidMixError, "Invalid texture #{texture_name} for Cinematic #@manifest_asset")
          geometry_name = map.keys.first
          geometry = @root_node.getChild(geometry_name)
          raise(InvalidMixError, "Child geometry #{geometry_name} not found for Cinematic #@manifest_asset}") unless geometry
          material = geometry.material rescue raise(InvalidMixError, "Geometry #{geometry_name} has no material for Cinematic #@manifest_asset}")
          # Validate the uniform name
          uniform_name = map[geometry_name]
          param = material.materialDef.getMaterialParam(uniform_name)
          if not param or param.varType != Jme::Shader::VarType::Texture2D
            raise(InvalidMixError, "Material for geometry #{geometry_name} does not have texture uniform #{uniform_name} for Cinematic #@manifest_asset")
          end
          UniformMaterial.new(uniform_name, material)
        end
      end
      private :uniform_materials

      def on_visual_render(visual_context, track_visual_contexts)
        if @configure_context
          visual_context.attach_child(@root_node)
          @camera_animation.visual_context = visual_context
          @configure_context = false
        end

        @uniform_materials.each_with_index do |uniform_material, i|
          texture = track_visual_contexts[i] && track_visual_contexts[i].prepare_texture
          uniform_material.apply(texture)
        end

        @camera_animation.animate(current_time)
      end

      def visual_context_released(context)
        @camera_animation.visual_context = nil
        @configure_context = true
      end

      def on_rendering_finished
        @root_node = nil
        @uniform_materials = nil
      end

      class UniformMaterial
        def initialize(uniform, material)
          @uniform = uniform
          @material = material
        end

        def apply(texture)
          @material.setTexture(@uniform, texture)
        end
      end

      class CameraAnimation
        def initialize(animation, aspect)
          @animator = Animation::Animator.new(animation)
          if @animator.camera
            # Convert from horizontal FOV in radians to vertical in degrees
            vertical_fov = @animator.camera.vertical_fov(aspect)
            @vertical_fov = Animation::CameraData.rad_to_deg(vertical_fov)
            @aspect = aspect
          end
        end

        def visual_context=(visual_context)
          @visual_context = visual_context
          if @visual_context and @animator.camera
            camera = @visual_context.camera
            camera.setFrustumPerspective(@vertical_fov, @aspect,
                                         @animator.camera.near,
                                         @animator.camera.far)
          end
        end

        def animate(time)
          @animator.evaluate_time(time)
          @visual_context.camera.setFrame(@animator.transform.translation,
                                          @animator.transform.rotation)
        end
      end
    end
  end
end
