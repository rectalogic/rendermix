# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Timeline
      # @param [PanZoom::Interpolator] interpolator object to perform
      #   keyframe interpolation, see {PanZoom::Linear} and
      #   {PanZoom::CatmullRom}
      # @param [Symbol] fit
      #   :meet prescale to fit within visual context,
      #   :fill prescale to fully fill visual context (may be scaled larger),
      #   :auto choose :meet or :fill whichever is closer.
      def initialize(interpolator, fit=:meet)
        @fit = fit
        @interpolator = interpolator
      end

      # @param [Float] time 0.0 to 1.0
      # @param [OrthoQuad] quad
      def panzoom(time, quad)
        scale, tx, ty = @interpolator.interpolate(time)
        quad.panzoom(scale, tx, ty)
      end
    end
  end
end
