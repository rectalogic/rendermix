# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class Animator
        # @return [Jme::Math::Transform] animation current transformation
        attr_reader :transform

        # @param [Hash] animation_data data loaded from Blender JSON export
        #  using the io_animation_rendermix addon.
        def initialize(animation_data)
          @begin_x, @end_x = animation_data.fetch('range')

          @location_x = create_interpolator(animation_data.fetch('locationX'))
          @location_y = create_interpolator(animation_data.fetch('locationY'))
          @location_z = create_interpolator(animation_data.fetch('locationZ'))
          @rotation_x = create_interpolator(animation_data.fetch('rotationX'))
          @rotation_y = create_interpolator(animation_data.fetch('rotationY'))
          @rotation_z = create_interpolator(animation_data.fetch('rotationZ'))

          # Horizontal field of view in radians (optional)
          #XXX expose this
          @horizontal_fov = animation_data['horizontalFOV']

          @transform = Jme::Math::Transform.new
        end

        def create_interpolator(interpolator_data)
          if interpolator_data.kind_of?(Numeric)
            return ConstantValueInterpolator.new(interpolator_data)
          else
            segments = interpolator_data.collect do |segment_data|
              BezierSegment.new(*segment_data.fetch('range'),
                                segment_data.fetch('bezierPoints'))
            end
            BezierCurveInterpolator.new(segments)
          end
        end
        private :create_interpolator

        # Evaluate for x which must be in the animations range
        # After evaluating, translation and rotation attributes will be updated.
        def evaluate(x)
          update_rotation(@rotation_x.evaluate(x),
                          @rotation_y.evaluate(x),
                          @rotation_z.evaluate(x))
          @transform.translation.set(@location_x.evaluate(x),
                                     @location_y.evaluate(x),
                                     @location_z.evaluate(x))
        end

        # @param [Float] time normalized time, 0..1
        def evaluate_time(time)
          # Evaluate x corresponding to time
          evaluate(@begin_x + time * (@end_x - @begin_x + 1))
        end

        # Update quaternion rotation from Euler XYZ
        # Rotation are Blender Euler angles of order XYZ - but Blender XYZ
        # is really ZYX order.
        def update_rotation(x, y, z)
          angle = x*0.5
          cx = Math.cos(angle)
          sx = Math.sin(angle)
          angle = y*0.5
          cy = Math.cos(angle)
          sy = Math.sin(angle)
          angle = z*0.5
          cz = Math.cos(angle)
          sz = Math.sin(angle)
          cxcz = cx*cz
          cxsz = cx*sz
          sxcz = sx*cz
          sxsz = sx*sz
          w = cy*cxcz + sy*sxsz
          x = cy*sxcz - sy*cxsz
          y = cy*sxsz + sy*cxcz
          z = cy*cxsz - sy*sxcz
          @transform.rotation.set(x, y, z, w).normalizeLocal
        end
        private :update_rotation
      end
    end
  end
end
