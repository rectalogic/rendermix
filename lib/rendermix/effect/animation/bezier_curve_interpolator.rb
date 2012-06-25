# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class BezierCurveInterpolator
        # @param [Array<BezierSegment>] segments ordered array of
        #  non-overlapping BezierSegments
        def initialize(segments)
          @segments = segments
          @current_segment = nil
        end

        # Binary search to find segment that contains x
        def find_segment(x)
          start_index = 0
          stop_index = @segments.length - 1
          middle_index = (stop_index + start_index) / 2

          while start_index < stop_index do
            segment = @segments[middle_index]
            if x < segment.begin_x
              stop_index = middle_index - 1
            elsif x > segment.end_x
              start_index = middle_index + 1
            else
              return segment
            end
            middle_index = (stop_index + start_index) / 2
          end

          # We failed to find the segment, return first or last.
          # Segment will clamp x to it's range.
          return @segments[middle_index]
        end
        private :find_segment

        def evaluate(x)
          # Find current segment if we are out of range
          if (@current_segment.nil? ||
              x < @current_segment.begin_x ||
              x > @current_segment.end_x)
            @current_segment = find_segment(x)
          end
          return @current_segment.evaluate(x)
        end
      end
    end
  end
end
