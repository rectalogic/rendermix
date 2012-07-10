# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Linear < Interpolator
      def interpolate_segment(amount)
        p0 = keyframes[current_index]
        p1 = keyframes[current_index + 1]
        scale = Jme::Math::FastMath::interpolateLinear(amount,
                                                       p0.scale, p1.scale)
        tx = Jme::Math::FastMath::interpolateLinear(amount, p0.tx, p1.tx)
        ty = Jme::Math::FastMath::interpolateLinear(amount, p0.ty, p1.ty)
        return scale, tx, ty
      end
    end
  end
end
