# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Timeline
      attr_reader :fit

      # @param [Array<PanZoom::Keyframe>] keyframes
      # @param [Hash] opts options
      # @option opts [String] :interpolator ("linear") which keyframe
      #   interpolation method to use - "linear" or "catmull".
      # @option opts [String] :fit ("meet") scaling mode.
      #   "meet" prescale to fit within visual context,
      #   "fill" prescale to fully fill visual context (may be scaled larger),
      #   "auto" choose :meet or :fill whichever is closer.
      def initialize(keyframes, opts={})
        opts.validate_keys(:interpolator, :fit)
        @fit = opts.fetch(:fit, "meet")
        case opts.fetch(:interpolator, "linear")
        when "linear"
          @interpolator = Linear.new(keyframes)
        when "catmull"
          @interpolator = CatmullRom.new(keyframes)
        else
          raise(InvalidMixError, "Invalid timeline interpolator")
        end
      end

      # @param [Float] time 0.0 to 1.0
      # @param [OrthoQuad] quad should be configured with this Timelines fit
      def panzoom(time, quad)
        scale, tx, ty = @interpolator.interpolate(time)
        quad.panzoom(scale, tx, ty)
      end
    end
  end
end
