# Copyright (c) 2012 Hewlett-Packard Development Company, L.P. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

module RenderMix
  module PanZoom
    class Keyframe
      attr_accessor :time
      attr_reader :scale
      attr_reader :tx
      attr_reader :ty
      def initialize(time, scale, tx, ty)
        @time = time
        @scale = scale
        @tx = tx
        @ty = ty
      end
    end
  end
end
