# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class Animator
        # @return [Jme::Math::Quaternion] animation rotation
        attr_reader :rotation
        # @return [Jme::Math::Vector3f] animation translation
        attr_reader :translation

        def initialize(animation_data)
          @begin_x, @end_x = animation_data['range']

          @location_x = create_interpolator(animation_data['locationX'])
          @location_y = create_interpolator(animation_data['locationY'])
          @location_z = create_interpolator(animation_data['locationZ'])
          @rotation_x = create_interpolator(animation_data['rotationX'])
          @rotation_y = create_interpolator(animation_data['rotationY'])
          @rotation_z = create_interpolator(animation_data['rotationZ'])

          # Horizontal field of view in radians (optional)
          #XXX expose this
          @horizontal_fov = animation_data['horizontalFOV']

          @rotation = Jme::Math::Quaternion.new
          @translation = Jme::Math::Vector3f.new
        end

        def create_interpolator(interpolator_data)
          if interpolator_data.kind_of?(Numeric)
            return ConstantValueInterpolator.new(interpolator_data)
          else
            segments = interpolator_data.collect do |segment_data|
              BezierSegment.new(*segment_data['range'],
                                segment_data['bezierPoints'])
            end
            BezierCurveInterpolator.new(segments)
          end
        end
        private :create_interpolator

        # Evaluate for x which must be in the animations range
        # After evaluating, translation and rotation attributes will be updated.
        # Rotation are Blender Euler angles of order XYZ - but Blender XYZ
        # is really ZYX order.
        def evaluate(x)
          @rotation.fromAngles(@rotation_x.evaluate(x),
                               @rotation_y.evaluate(x),
                               @rotation_z.evaluate(x))
          @translation.set(@location_x.evaluate(x),
                           @location_y.evaluate(x),
                           @location_z.evaluate(x))
        end

        # @param [Float] time normalized time, 0..1
        def evaluate_time(time)
          # Evaluate x corresponding to time
          evaluate(@begin_x + time * (@end_x - @begin_x + 1))
        end
      end
    end
  end
end
