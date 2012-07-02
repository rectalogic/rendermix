# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class CameraData
        attr_reader :horizontal_fov
        attr_reader :near
        attr_reader :far

        def initialize(horizontal_fov, near, far)
          @horizontal_fov = horizontal_fov
          @near = near
          @far = far
        end

        # @param [Float] aspect width / height
        def vertical_fov(aspect)
          2 * Math.atan(Math.tan(@horizontal_fov / 2.0) / aspect)
        end

        # Convert radians to degrees
        def self.rad_to_deg(rad)
          rad * 180.0 / Math::PI
        end
      end
    end
  end
end
