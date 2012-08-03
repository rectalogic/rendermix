# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    # A cinematic effect is typically a 3D animation, with texture
    # tracks applied to surface materials in the models.
    class Cinematic < VisualBase
      # @example Manifest JSON format:
      #   {
      #       "scenes" : [ "<asset-path-to-j3o>", ... ],
      #       "textures" : {
      #           "<TextureName>" : { "geometry": "<GeometryName>",
      #                               "uniform": "<UniformName>" },
      #           ...
      #       },
      #       "texts": {
      #           "<TextName>": {
      #               "texture": "<TextureName>",
      #               <TextParameters>
      #           },
      #           ...
      #       },
      #       "camera" : "<asset-path-to-camera-animation-json>"
      #   }
      #
      # "UniformName" is the name of a texture uniform on the
      # Jme::Material::Material associated with the Jme::Scene::Geometry
      # named "GeometryName"
      # "TextParameters" are additional text configuration paramaters,
      # see {TextTexture#create_text_texture}
      # @param [String] manifest_asset asset path to manifest JSON
      # @param [Array<String>] track_textures array of "TextureName"s
      #   from the manifest. These are in track order (i.e. the first texture
      #   name will be used for the first track etc.)
      # @param [Hash] text_values hash mapping text "TextName" keys to
      #   String text values.
      def initialize(manifest_asset, track_textures=[], text_values={})
        super()
        @manifest_asset = manifest_asset
        @track_textures = track_textures
        @text_values = text_values
      end

      def on_rendering_prepare(context_manager)
        # Load manifest JSON
        manifest = Asset::JSONLoader.load(mixer.asset_manager, @manifest_asset)
        manifest.validate_keys("scenes", "textures", "texts", "camera")

        # Attach all model files to root node
        @root_node = Jme::Scene::Node.new("Cinematic")
        scenes = manifest.fetch('scenes') rescue raise(InvalidMixError, "Missing scenes key for #@manifest_asset")
        scenes.each do |scene|
          model = mixer.asset_manager.loadModel(scene)
          @root_node.attachChild(model)
        end

        manifest_textures = manifest.fetch('textures', {})
        @track_materials = create_track_materials(manifest_textures)

        manifest_texts = manifest.fetch('texts', {})
        apply_text_textures(manifest_texts, manifest_textures)

        camera_asset = manifest.fetch('camera') rescue raise(InvalidMixError, "Missing camera animation for #@manifest_asset")
        animation = Asset::JSONLoader.load(mixer.asset_manager, camera_asset)
        @camera_animation = CameraAnimation.new(animation, mixer.width / mixer.height.to_f) rescue raise(InvalidMixError, "Camera animation corrupt #{camera_asset}")

        @configure_context = true
      end

      def apply_text_textures(manifest_texts, manifest_textures)
        @text_values.each_pair do |text_name, text|
          # Symbolize keys dups
          text_options = manifest_texts.fetch(text_name).symbolize_keys rescue raise(InvalidMixError, "Invalid text #{text_name} for Cinematic #@manifest_asset")
          texture_name = text_options.delete(:texture)
          raise(InvalidMixError, "Missing texture key for text #{text_name} in Cinematic #@manifest_asset") unless texture_name
          texture_map = manifest_textures.fetch(texture_name) rescue raise(InvalidMixError, "Invalid texture #{texture_name} for text #{text_name} in Cinematic #@manifest_asset")
          texture = create_text_texture(text, text_options)
          create_uniform_material(texture_map).apply(texture)
        end
      end
      private :apply_text_textures

      def create_track_materials(manifest_textures)
        @track_textures.collect do |texture_name|
          texture_map = manifest_textures.fetch(texture_name) rescue raise(InvalidMixError, "Invalid texture #{texture_name} for Cinematic #@manifest_asset")
          create_uniform_material(texture_map)
        end
      end
      private :create_track_materials

      # @return [UniformMaterial] mapping uniform name to Jme::Material::Material
      def create_uniform_material(texture_map)
        texture_map.validate_keys('geometry', 'uniform')
        geometry_name = texture_map.fetch("geometry") rescue raise(InvalidMixerror, "Missing geometry key for Cinematic #@manifest_asset")
        geometry = @root_node.getChild(geometry_name)
        raise(InvalidMixError, "Child geometry #{geometry_name} not found for Cinematic #@manifest_asset}") unless geometry
        material = geometry.material rescue raise(InvalidMixError, "Geometry #{geometry_name} has no material for Cinematic #@manifest_asset}")
        # Validate the uniform name
        uniform_name = texture_map.fetch("uniform") rescue raise(InvalidMixError, "Missing uniform key for Cinematic #@manifest_asset")
        param = material.materialDef.getMaterialParam(uniform_name)
        if not param or param.varType != Jme::Shader::VarType::Texture2D
          raise(InvalidMixError, "Material for geometry #{geometry_name} does not have texture uniform #{uniform_name} for Cinematic #@manifest_asset")
        end
        UniformMaterial.new(uniform_name, material)
      end
      private :create_uniform_material

      def on_visual_render(context_manager, visual_context, track_visual_contexts)
        # Cinematics want antialiasing
        context_manager.request_antialias

        if @configure_context
          visual_context.attach_child(@root_node)
          @camera_animation.visual_context = visual_context
          @configure_context = false
        end

        @track_materials.each_with_index do |uniform_material, i|
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
        @track_materials = nil
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
