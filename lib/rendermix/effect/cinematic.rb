# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    # A cinematic effect is typically a 3D animation, with texture
    # tracks applied to surface materials in the models.
    class Cinematic < VisualBase
      # @example Manifest JSON format:
      #   {
      #       "scenes": [ "<asset-path-to-j3o>", ... ],
      #       "filter": "<asset-path-to-j3f>",
      #       "antialias": <Boolean>,
      #       "textures": {
      #           "<TextureName>" : [ { "geometry": "<GeometryName>",
      #                                 "uniform": "<UniformName>" },
      #                               ...
      #                             ],
      #           ...
      #       },
      #       "buffers": [
      #           { "geometry": "<GeometryName>",
      #             "buffer": [<Numeric>, ...],
      #             "components": <Fixnum>,
      #             "format": <Jme::Scene::VertexBuffer::Format>,
      #             "type": <Jme::Scene::VertexBuffer::Type> },
      #           ...
      #       ],
      #       "animations": [
      #           { "spatial": "<SpatialName>",
      #             "animation": "<AnimationName>" },
      #           ...
      #       ],
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
      # * "scenes" - array of j3o scene files
      # * "filter" - optional path to j3f filter post processor.
      #   This should not contain an FXAA filter.
      # * "antialias" - boolean, true if FXAA antialias should be used.
      #   Default is true.
      # * "textures" - hash mapping "TextureName" to array of hashes
      #   containing a "UniformName" of a texture uniform on the
      #   Jme::Material::Material associated with the Jme::Scene::Geometry
      #   named "GeometryName"
      # * "buffers" - optional array of hashes mapping a Jme::Scene::Geometry
      #   named "GeometryName" to a Jme::Scene::VertexBuffer definition.
      #   This is mostly useful for applying a second set of texture
      #   coordinates to a simple quad mesh shape.
      #   * "buffer" is an array of numeric values.
      #   * "components" is the number of components per entry (e.g. 2).
      #   * "format" is the format name (e.g. "Float")
      #   * "type" is the buffer type name (e.g. "TexCoord2")
      # * "animations" - optional array of hashes mapping a
      #   Jme::Scene::Spatial named "SpatialName" to an animation channel
      #   named "AnimationName"
      # * "texts" - optional hash mapping "TextName" to the "TextureName"
      #   from "textures" that rendered text should be applied to.
      #   "TextParameters" are additional text configuration paramaters,
      #   see {TextTexture#create_text_texture}
      # * "camera" - path to JSON animation file exported from Blender
      #
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
        manifest = Asset::JSONLoader.load(mixer.render_system.asset_manager, @manifest_asset)
        manifest.validate_keys("scenes", "buffers", "filter", "textures", "animations", "texts", "camera")

        @visual_context = VisualContext.new(mixer,
                                            depth: true,
                                            clear_flags: [true, true, true])

        load_scenes(manifest)

        load_buffers(manifest)

        textures = manifest.fetch('textures', {})
        texts = manifest.fetch('texts', {})

        load_textures(textures)
        load_texts(texts, textures)

        load_animations(manifest)
        load_camera(manifest)

        load_filter_antialias(manifest)
      end

      def load_scenes(manifest)
        # Attach all model files to root node
        scenes = manifest.fetch('scenes') rescue error("Missing key 'scenes'")
        scenes.each do |scene|
          model = mixer.render_system.asset_manager.loadModel(scene)
          @visual_context.rootnode.attachChild(model)
        end
      end
      private :load_scenes

      def load_buffers(manifest)
        return unless buffers = manifest['buffers']
        vb = Jme::Scene::VertexBuffer
        buffers.each do |buffer|
          geometry_name = buffer.fetch('geometry') rescue error("Missing 'buffers' key 'geometry'")
          geometry = @visual_context.rootnode.getChild(geometry_name) || error("Invalid 'geometry' name #{geometry_name}")

          data = buffer.fetch('buffer').to_a rescue error("Missing 'buffers' key 'buffer'")
          components = buffer.fetch('components').to_i rescue error("Missing 'buffers' key 'components'")
          format = vb::Format::valueOf(buffer.fetch('format')) rescue error("Missing/invalid 'buffers' key 'format'")
          type = vb::Type::valueOf(buffer.fetch('type')) rescue error("Missing/invalid 'buffers' key 'type'")

          set_vertex_buffer(geometry.mesh, data, components, format, type)
        end
      end
      private :load_buffers

      def load_textures(textures)
        @track_materials = @track_textures.collect do |texture_name|
          texture_maps = textures.fetch(texture_name) rescue error("Invalid texture name #{texture_name}")
          texture_maps.collect do |texture_map|
            create_uniform_material(texture_map)
          end
        end
      end
      private :load_textures

      def load_texts(texts, textures)
        @text_values.each_pair do |text_name, text|
          # Symbolize keys dups
          text_options = texts.fetch(text_name).symbolize_keys rescue error("Invalid text name #{text_name}")
          texture_name = text_options.delete(:texture) || error(%Q(Missing key "texture" for text "#{text_name}"))
          texture_maps = textures.fetch(texture_name) rescue error("Invalid texture #{texture_name} for text #{text_name}")
          texture = create_text_texture(text, text_options)
          texture_maps.each do |texture_map|
            create_uniform_material(texture_map).apply(texture)
          end
        end
      end
      private :load_texts

      def load_animations(manifest)
        return unless animations = manifest['animations']
        @animations = animations.collect do |animation|
          spatial_name = animation.fetch("spatial") rescue error("Missing 'animations' key 'spatial'")
          spatial = @visual_context.rootnode.getChild(spatial_name) || error("Invalid 'spatial' name #{spatial_name}")
          anim_name = animation.fetch("animation") rescue error("Missing 'animations' key 'animation'")
          SpatialAnimation.new(spatial, anim_name)
        end
      end
      private :load_animations

      def load_camera(manifest)
        camera_asset = manifest.fetch('camera') rescue error("Missing key 'camera'")
        animation = Asset::JSONLoader.load(mixer.render_system.asset_manager, camera_asset)
        @camera_animation = CameraAnimation.new(animation, @visual_context.camera) rescue error("Camera animation corrupt #{camera_asset}")
      end
      private :load_camera

      def load_filter_antialias(manifest)
        filter = manifest.fetch('filter', nil)
        # This won't be cached
        fpp = mixer.render_system.asset_manager.loadFilter(filter) if filter

        # Add FXAA antialias filter if requested
        if manifest.fetch('antialias', true)
          fpp ||= Jme::Post::FilterPostProcessor.new(mixer.render_system.asset_manager)
          fxaa = Jme::Post::Filters::FXAAFilter.new
          # Higher quality, but blurrier
          fxaa.subPixelShift = 0
          fxaa.reduceMul = 0
          fpp.addFilter(fxaa)
        end
        @visual_context.viewport.addProcessor(fpp) if fpp
      end
      private :load_filter_antialias

      # @return [UniformMaterial] mapping uniform name to Jme::Material::Material
      def create_uniform_material(texture_map)
        texture_map.validate_keys('geometry', 'uniform')
        geometry_name = texture_map.fetch("geometry") rescue error("Missing 'textures' key 'geometry'")
        geometry = @visual_context.rootnode.getChild(geometry_name) || error("Invalid 'geometry' name #{geometry_name}")
        material = geometry.material rescue error("Geometry #{geometry_name} has no material")
        # Validate the uniform name
        uniform_name = texture_map.fetch("uniform") rescue error("Missing 'textures' key 'uniform'")
        param = material.materialDef.getMaterialParam(uniform_name)
        if not param or param.varType != Jme::Shader::VarType::Texture2D
          error("Material for geometry #{geometry_name} does not have texture uniform #{uniform_name}")
        end
        UniformMaterial.new(uniform_name, material)
      end
      private :create_uniform_material

      # @param [Jme::Scene::Mesh] mesh
      # @param [Array<Numeric>] data
      # @param [Fixnum] components
      # @param [Jme::Scene::VertexBuffer::Format] format
      # @param [Jme::Scene::VertexBuffer::Type] type
      def set_vertex_buffer(mesh, data, components, format, type)
        vb = Jme::Scene::VertexBuffer
        bu = Jme::Util::BufferUtils
        buffer =
          case format
          when vb::Format::Float
            bu::createFloatBuffer(*data)
          when vb::Format::Byte
            bu::createByteBuffer(*data)
          when vb::Format::Int
            bu::createIntBuffer(*data)
          when vb::Format::Short
            bu::createShortBuffer(*data)
          else
            error("Unsupported buffer format '#{format}'")
          end

        vertex_buffer = vb.new(type)
        vertex_buffer.setupData(vb::Usage::Static, components, format, buffer)
        mesh.clearBuffer(type)
        mesh.setBuffer(vertex_buffer)
      end
      private :set_vertex_buffer

      def error(msg)
        raise(InvalidMixError, %Q(#{msg} for Cinematic #@manifest_asset))
      end
      private :error

      def on_visual_render(context_manager, track_visual_contexts)
        context_manager.context = @visual_context

        #XXX we should check that all remaining track_visual_contexts are nil - i.e. don't want to be rendering tracks that aren't consumed
        @track_materials.each_with_index do |uniform_materials, i|
          vc = track_visual_contexts[i]
          texture = vc.render_scene if vc
          #XXX set filtering on texture?
          uniform_materials.each do |uniform_material|
            uniform_material.apply(texture)
          end
        end

        @camera_animation.animate(current_time)

        @animations.each {|a| a.animate(current_time) } if @animations
      end

      def on_rendering_finished
        @visual_context = nil
        @camera_animation = nil
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

      class SpatialAnimation
        def initialize(spatial, anim_name)
          control = spatial.getControl(Jme::Animation::AnimControl.java_class)
          @channel = control.createChannel
          @channel.setAnim(anim_name)
          @duration = @channel.animMaxTime
          #XXX support realtime/looping option in manifest - in which case we just leave speed alone and let them animate
          @channel.setSpeed(0)
        end

        def animate(time)
          @channel.setTime(time * @duration)
        end
      end

      class CameraAnimation
        # @param [Hash] animation camera animation data
        # @param [Jme::Renderer::Camera] camera
        def initialize(animation, camera)
          @animator = Animation::Animator.new(animation)
          @camera = camera
          if @animator.camera
            # Convert from horizontal FOV in radians to vertical in degrees
            aspect = camera.width / camera.height.to_f
            vertical_fov = @animator.camera.vertical_fov(aspect) *
              Jme::Math::FastMath::RAD_TO_DEG
            camera.setFrustumPerspective(vertical_fov, aspect,
                                         @animator.camera.near,
                                         @animator.camera.far)
          end
        end

        def animate(time)
          @animator.evaluate_time(time)
          @camera.setFrame(@animator.transform.translation,
                           @animator.transform.rotation)
        end
      end
    end
  end
end
