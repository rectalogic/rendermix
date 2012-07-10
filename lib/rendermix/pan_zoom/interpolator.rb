# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Interpolator
      attr_reader :keyframes
      attr_accessor :current_index

      # @param [Array<PanZoom::Keyframe>] keyframes time ordered keyfranes.
      #   First keyframe will be forced to time 0.0, last to 1.0.
      def initialize(keyframes)
        @keyframes = keyframes.dup
        # Duplicate single keyframe
        @keyframes.push(@keyframes.first.clone) if @keyframes.length == 1
        @keyframes.first.time = 0.0
        @keyframes.last.time = 1.0

        # Validate ordering
        time = 0.0
        @keyframes.each do |kf|
          raise(InvalidMixError, "PanZoom Keyframes not ordered") if kf.time < time
          time = kf.time
        end

        @current_index = 0
      end

      def interpolate(time)
        @current_index += 1 if time > @keyframes[@current_index + 1].time
        range = @keyframes[@current_index + 1].time - @keyframes[@current_index].time
        amount = (time - @keyframes[@current_index].time) / range.to_f
        interpolate_segment(amount)
      end
    end
  end
end
