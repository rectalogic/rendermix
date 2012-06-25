# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module Effect
    module Animation
      class BezierSegment
        TOLERANCE = 0.000001
        ITERATIONS = 5

        attr_reader :begin_x
        attr_reader :end_x

        # @param [Float] begin_x starting x coordinate that endpoints
        #  of this segment cover
        # @param [Float] end_x ending x coordinate that endpoints
        #  of this segment cover
        # @param [Array<p1,p2,p3,p4>] control_points array of four Bezier [x,y]
        #  control points. e.g. [[ax,ay],[bx,by],[cx,cy],[dx,dy]]
        #  See http://www.flong.com/texts/code/shapers_bez/
        def initialize(begin_x, end_x, control_points)
          @begin_x = begin_x
          @end_x = end_x
          @x_coefficients = polynomial_coefficients(control_points, 0)
          @y_coefficients = polynomial_coefficients(control_points, 1)
        end

        # Return polynomial coefficients [a,b,c,d] for control
        # points in p (array of 4 [x,y] control points),
        # for coordinate i (0 for x, 1 for y).
        # See http://www.cs.binghamton.edu/~reckert/460/bezier.htm
        # @param [Array<p1,p2,p3,p4>] p array of four Bezier control points
        # @param [Fixnum] i coordinate to use (0 for x, 1 for y)
        # @return [Array<a,b,c,d>] polynomical coefficients
        def polynomial_coefficients(p, i)
          [p[3][i] - 3 * p[2][i] + 3 * p[1][i] - p[0][i],
           3 * p[2][i] - 6 * p[1][i] + 3 * p[0][i],
           3 * p[1][i] - 3 * p[0][i],
           p[0][i]]
        end
        private :polynomial_coefficients

        # @param [Float] x value to evaluate segment for
        # @return [Float] y value for given x
        def evaluate(x)
          # Solve for t given x (using Newton-Raphson), then solve for
          # y given t.
          # For first guess, linearly interpolate to get t.
          t = x / (@end_x - @begin_x + 1)
          old_t = t
          ITERATIONS.times do |i|
            current_x = evaluate_polynomial(t, @x_coefficients)
            current_slope = slope(t, @x_coefficients)
            t -= (current_x - x) * current_slope
            t = clamp(t)
            break if (old_t - t).abs <= TOLERANCE
            old_t = t
          end

          evaluate_polynomial(t, @y_coefficients)
        end

        # @param [Float] t time to evaluate cubic polynomial at
        # @param [Array<a,b,c,d>] c polynomial coefficients [a,b,c,d]
        def evaluate_polynomial(t, c)
          # Use Horners rule for polynomial evaluation
          ((c[0] * t + c[1]) * t + c[2]) * t + c[3]
        end
        private :evaluate_polynomial

        # @param [Float] t time
        # @param [Array<a,b,c,d>] c coefficients
        # @return [Float] slope for given time t for coefficients c
        def slope(t, c)
          1.0 / (3.0 * c[0] * t * t + 2.0 * c[1] * t + c[2])
        end
        private :slope

        # @param [Float] v value to clamp to 0..1
        # @return [Float] clamped value in range 0..1
        def clamp(v)
          v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v)
        end
        private :clamp
      end
    end
  end
end
