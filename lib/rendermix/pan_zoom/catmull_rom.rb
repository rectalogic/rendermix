# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class CatmullRom < Interpolator
      def initialize(keyframes)
        super
        # Double up first and last keyframes
        self.keyframes.unshift(self.keyframes.first.clone)
        self.keyframes.push(self.keyframes.last.clone)
        self.current_index = 1
      end

      def interpolate_segment(amount)
        p0 = keyframes[current_index - 1]
        p1 = keyframes[current_index]
        p2 = keyframes[current_index + 1]
        p3 = keyframes[current_index + 2]
        scale = Jme::Math::FastMath::interpolateCatmullRom(amount, 0.5,
                                                           p0.scale, p1.scale,
                                                           p2.scale, p3.scale)
        tx = Jme::Math::FastMath::interpolateCatmullRom(amount, 0.5,
                                                        p0.tx, p1.tx,
                                                        p2.tx, p3.tx)
        ty = Jme::Math::FastMath::interpolateCatmullRom(amount, 0.5,
                                                        p0.ty, p1.ty,
                                                        p2.ty, p3.ty)
        return scale, tx, ty
      end
    end
  end
end
